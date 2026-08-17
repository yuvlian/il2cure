package il2cpp

// gc-safe managed field read/write via the il2cpp api.
// prefer these over raw offset reads! why?
// cuzthe runtime handles boxing/unboxing and keeps the value alive across the access!
//
// field_read/write copy an unboxed value into/from a caller buffer of the field's underlying type
//
// for reference-typed fields use field_read_object / field_read_string to
// get the live reference (no manual pin needed)
//
// field handles are stable for the lifetime of the class; resolve once with
// field_of and reuse (avoid re-scanning le field iterator per access)

// resolves class's field by name
field_of :: proc (class: Il2CppClass, name: string) -> (Il2CppField, bool) {
	if class == 0 {
		return {}, false
	}
	iter: rawptr
	for {
		f := vm_il2cpp_class_get_fields(class, &iter)
		if f == 0 {
			break
		}
		if string(vm_il2cpp_field_get_name(f)) == name {
			return f, true
		}
	}
	return {}, false
}

// field_offset is the version-aware raw offset accessor (it is in version.odin)
// prefer field_read unlesss need 2 skip the runtime call.

// copies the unboxed value of a field on obj into value,
// a pointer to storage of the field's underlying type (i32/f32/struct,
// or a pointer for reference types)
field_read :: proc (obj: Il2CppObject, field: Il2CppField, value: rawptr) {
	vm_il2cpp_field_get_value(obj, field, value)
}

// sets a field on obj from an unboxed value buffer
field_write :: proc (obj: Il2CppObject, field: Il2CppField, value: rawptr) {
	vm_il2cpp_field_set_value(obj, field, value)
}

// returns the live ref of a ref typed fiedl
field_read_object :: proc (
	field: Il2CppField,
	obj:   Il2CppObject,
	class: Il2CppClass = 0,
) -> Il2CppObject {
	return vm_il2cpp_field_get_value_object(field, obj, class)
}

// sets a ref typed field to a managed obj
field_write_object :: proc (
	class: Il2CppClass,
	obj:   Il2CppObject,
	field: Il2CppField,
	value: Il2CppObject,
) {
	vm_il2cpp_field_set_value_object(class, obj, field, value)
}

// decodes a string-typed field to utf8.
// caller must delete the returned string (it was allocated from allocator).
field_read_string :: proc (
	obj:        Il2CppObject,
	field:      Il2CppField,
	allocator := context.allocator,
) -> (string, bool) {
	s := vm_il2cpp_field_get_value_object(field, obj, 0)
	if s == 0 {
		return "", false
	}
	return string_to_utf8(Il2CppString(s), allocator)
}

// field_read but for static
field_static_read :: proc (field: Il2CppField, value: rawptr) {
	vm_il2cpp_field_static_get_value(field, value)
}

// field_write but for static
field_static_write :: proc (field: Il2CppField, value: rawptr) {
	vm_il2cpp_field_static_set_value(field, value)
}

// field_read_object but for static
field_static_read_object :: proc (field: Il2CppField, class: Il2CppClass) -> Il2CppObject {
	return vm_il2cpp_field_get_value_object(field, 0, class)
}

// field_write_object but for static
field_static_write_object :: proc (
	class: Il2CppClass,
	field: Il2CppField,
	value: Il2CppObject,
) {
	vm_il2cpp_field_set_value_object(class, 0, field, value)
}
