package reflection

import "../il2cpp"

Runtime_Type :: distinct uintptr

Binding_Flags :: distinct u32

Binding_Flags_Default              :: Binding_Flags(0)
Binding_Flags_IgnoreCase           :: Binding_Flags(0x00001)
Binding_Flags_DeclaredOnly         :: Binding_Flags(0x00002)
Binding_Flags_Instance             :: Binding_Flags(0x00004)
Binding_Flags_Static               :: Binding_Flags(0x00008)
Binding_Flags_Public               :: Binding_Flags(0x00010)
Binding_Flags_NonPublic            :: Binding_Flags(0x00020)
Binding_Flags_FlattenHierarchy     :: Binding_Flags(0x00040)
Binding_Flags_InvokeMethod         :: Binding_Flags(0x00100)
Binding_Flags_ExactBinding         :: Binding_Flags(0x10000)
Binding_Flags_OptionalParamBinding :: Binding_Flags(0x40000)

// filters a method's MethodAttributes against the requested
// BindingFlags via il2cpp_method_get_flags
method_visible :: proc (method: il2cpp.Il2CppMethod, flags: Binding_Flags) -> bool {
	attrs := Method_Attributes(il2cpp.vm_il2cpp_method_get_flags(method, nil))

	want_public := has_flags(flags, Binding_Flags_Public)
	want_nonpublic := has_flags(flags, Binding_Flags_NonPublic)
	is_public := has_flags(
		attrs & Method_Attributes_MemberAccessMask,Method_Attributes_Public)
	if want_public && !is_public { return false }
	if want_nonpublic && is_public { return false }

	want_static := has_flags(flags, Binding_Flags_Static)
	want_instance := has_flags(flags, Binding_Flags_Instance)
	is_static := has_flags(attrs, Method_Attributes_Static)
	if want_static && !is_static { return false }
	if want_instance && is_static { return false }

	return true
}

param_type_name :: proc (method: il2cpp.Il2CppMethod, i: u32) -> string {
	pt := il2cpp.vm_il2cpp_method_get_param(method, i)
	if pt == 0 {
		return ""
	}
	return type_il_name(pt)
}

// finds a method on class by name whose parameter count
// and type-name list exactly match arg_types
find_method_specific :: proc (
	class:      il2cpp.Il2CppClass,
	name:       string,
	binding:    Binding_Flags = Binding_Flags_Default,
	arg_types:  []string      = {},
) -> (il2cpp.Il2CppMethod, bool) {
	iter: rawptr
	for {
		method := il2cpp.vm_il2cpp_class_get_methods(class, &iter)
		if method == 0 {
			break
		}
		if binding != Binding_Flags_Default && !method_visible(method, binding) {
			continue
		}
		mname := string(il2cpp.vm_il2cpp_method_get_name(method))
		if mname != name {
			continue
		}
		arity := int(il2cpp.vm_il2cpp_method_get_param_count(method))
		if arity != len(arg_types) {
			continue
		}
		match := true
		for i in 0 ..< arity {
			if param_type_name(method, u32(i)) != arg_types[i] {
				match = false
				break
			}
		}
		if match {
			return method, true
		}
	}
	return {}, false
}

// wraps a class as its System.Type object.
runtime_type_of_class :: proc (class: il2cpp.Il2CppClass) -> Runtime_Type {
	return Runtime_Type(il2cpp.vm_il2cpp_class_get_type(class))
}

// finds on a System.Type object by name + arg types
// requires the il2cpp package's tables to resolve the underlying class
find_method_specific_on :: proc (
	t:          Runtime_Type,
	name:       string,
	binding:    Binding_Flags = Binding_Flags_Default,
	arg_types:  []string      = {},
) -> (il2cpp.Il2CppMethod, bool) {
	class := il2cpp.vm_il2cpp_class_from_type(il2cpp.Il2CppType(uintptr(t)))
	if class == 0 {
		return {}, false
	}
	return find_method_specific(class, name, binding, arg_types)
}
