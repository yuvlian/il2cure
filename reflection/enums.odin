package reflection

import "../il2cpp"

// is_enum?
enum_is_enum :: proc (class: il2cpp.Il2CppClass) -> bool {
	return il2cpp.vm_il2cpp_class_is_enum(class)
}

// returns the enum's underlying type, e.g. System.Int32 / System.Byte
enum_underlying_type :: proc (class: il2cpp.Il2CppClass) -> (il2cpp.Il2CppType, bool) {
	if !enum_is_enum(class) {
		return {}, false
	}
	t := il2cpp.vm_il2cpp_class_enum_basetype(class)
	if t == 0 {
		return {}, false
	}
	return t, true
}

// returns the underlying type's name ("Int32") or "" when not enum
enum_underlying_name :: proc (class: il2cpp.Il2CppClass) -> string {
	t, ok := enum_underlying_type(class)
	if !ok {
		return ""
	}
	return string(il2cpp.vm_il2cpp_type_get_name(t))
}

// lists the enum's constant fields (literal instance fields).
// returns nil if not enum
// caller must delete the returned slice
enum_fields :: proc (class: il2cpp.Il2CppClass, allocator := context.allocator) -> []Field_Info {
	if !enum_is_enum(class) {
		return nil
	}
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
