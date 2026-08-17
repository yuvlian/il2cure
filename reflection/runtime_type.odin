package reflection

import "../il2cpp"

// returns the type's name as encoded in the metadata
// (eg."List`1", "Int32").
type_il_name :: proc (t: il2cpp.Il2CppType) -> string {
	return string(il2cpp.vm_il2cpp_type_get_name(t))
}

// reports whether the type is a by-reference type
type_is_byref :: proc (t: il2cpp.Il2CppType) -> bool {
	return il2cpp.vm_il2cpp_type_is_byref(t)
}

// type_class returns the type's backing class
// (or its element class for byref/array types).
// 0 if none
type_class :: proc (t: il2cpp.Il2CppType) -> il2cpp.Il2CppClass {
	return il2cpp.vm_il2cpp_type_get_class_or_element_class(t)
}

// returns the Type_Attributes flag word of the type's backing class, or 0
type_attributes :: proc (t: il2cpp.Il2CppType) -> Type_Attributes {
	c := type_class(t)
	if c == 0 {
		return Type_Attributes(0)
	}
	return Type_Attributes(il2cpp.vm_il2cpp_type_get_attrs(t))
}

class_is_interface :: proc (class: il2cpp.Il2CppClass) -> bool {
	return il2cpp.vm_il2cpp_class_is_interface(class)
}

class_is_abstract :: proc (class: il2cpp.Il2CppClass) -> bool {
	return il2cpp.vm_il2cpp_class_is_abstract(class)
}

class_is_valuetype :: proc (class: il2cpp.Il2CppClass) -> bool {
	return il2cpp.vm_il2cpp_class_is_valuetype(class)
}

// class_base_types returns the inheritance chain class, its parent,
// ... up to (not including) System.Object
class_base_types :: proc (
	class: il2cpp.Il2CppClass,
	allocator := context.allocator,
) -> []il2cpp.Il2CppClass {
	chain := make([dynamic]il2cpp.Il2CppClass, allocator)
	for k := class; k != 0; k = il2cpp.vm_il2cpp_class_get_parent(k) {
		append(&chain, k)
	}
	return chain[:]
}

// returns the interfaces class implements
class_interfaces :: proc (
	class: il2cpp.Il2CppClass,
	allocator := context.allocator,
) -> []il2cpp.Il2CppType {
	its := make([dynamic]il2cpp.Il2CppType, allocator)
	iter: rawptr
	for {
		it := il2cpp.vm_il2cpp_class_get_interfaces(class, &iter)
		if it == 0 {
			break
		}
		append(&its, it)
	}
	return its[:]
}

class_all_fields :: proc (class: il2cpp.Il2CppClass, allocator := context.allocator) -> []Field_Info {
	out := make([dynamic]Field_Info, allocator)
	iter: rawptr
	for {
		f := il2cpp.vm_il2cpp_class_get_fields(class, &iter)
		if f == 0 {
			break
		}
		append(&out, Field_Info(f))
	}
	return out[:]
}

class_all_methods :: proc (class: il2cpp.Il2CppClass, allocator := context.allocator) -> []Method_Info {
	out := make([dynamic]Method_Info, allocator)
	iter: rawptr
	for {
		m := il2cpp.vm_il2cpp_class_get_methods(class, &iter)
		if m == 0 {
			break
		}
		append(&out, Method_Info(m))
	}
	return out[:]
}

class_all_properties :: proc (class: il2cpp.Il2CppClass, allocator := context.allocator) -> []Property_Info {
	out := make([dynamic]Property_Info, allocator)
	iter: rawptr
	for {
		p := il2cpp.vm_il2cpp_class_get_properties(class, &iter)
		if p == 0 {
			break
		}
		append(&out, Property_Info(p))
	}
	return out[:]
}

