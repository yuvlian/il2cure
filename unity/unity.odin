package unity

import "core:math"

import "../il2cpp"

Color :: struct #packed {
	r, g, b, a: f32,
}

find_method :: proc (
	class:     il2cpp.Il2CppClass,
	name:      string,
	arg_types: []string = nil,
) -> (il2cpp.Il2CppMethod, bool) {
	iter: rawptr
	for {
		method := il2cpp.vm_il2cpp_class_get_methods(class, &iter)
		if method == 0 {
			break
		}
		if string(il2cpp.vm_il2cpp_method_get_name(method)) != name {
			continue
		}
		if arg_types != nil {
			if int(il2cpp.vm_il2cpp_method_get_param_count(method)) != len(arg_types) {
				continue
			}
			matched := true
			for i in 0 ..< len(arg_types) {
				t := il2cpp.vm_il2cpp_method_get_param(method, u32(i))
				if t == 0 {
					matched = false
					break
				}
				if string(il2cpp.vm_il2cpp_type_get_name(t)) != arg_types[i] {
					matched = false
					break
				}
			}
			if !matched {
				continue
			}
		}
		return method, true
	}
	return {}, false
}

invoke :: proc (
	self:    il2cpp.Il2CppObject,
	class:   il2cpp.Il2CppClass,
	method:  il2cpp.Il2CppMethod,
	args:    []uintptr,
) -> (il2cpp.Il2CppObject, bool) {
	exc := il2cpp.Il2CppException(0)
	res := il2cpp.vm_il2cpp_runtime_invoke(
		method,
		self,
		cast(^rawptr)(raw_data(args)),
		&exc,
	)
	return res, exc == 0
}

invoke_named :: proc (
	self:      il2cpp.Il2CppObject,
	class:     string,
	name:      string,
	arg_types: []string = nil,
	args:      []uintptr = nil,
) -> (il2cpp.Il2CppObject, bool) {
	class, found := il2cpp.find_class(class)
	if !found {
		return {}, false
	}
	method, mok := find_method(class, name, arg_types)
	if !mok {
		return {}, false
	}
	return invoke(self, class, method, args)
}

get_class_of :: proc (obj: il2cpp.Il2CppObject) -> il2cpp.Il2CppClass {
	return il2cpp.vm_il2cpp_object_get_class(obj)
}

read_value :: proc (obj: il2cpp.Il2CppObject, $T: typeid) -> (T, bool) {
	if obj == 0 {
		return {}, false
	}
	data := il2cpp.vm_il2cpp_object_unbox(obj)
	if data == nil {
		return {}, false
	}
	return (^T)(data)^, true
}

unbox_bool :: proc (obj: il2cpp.Il2CppObject) -> bool {
	data := il2cpp.vm_il2cpp_object_unbox(obj)
	if data == nil {
		return false
	}
	return (^u32)(data)^ != 0
}

math_clamp01 :: proc (v: f32) -> f32 { return math.clamp(v, 0.0, 1.0) }
