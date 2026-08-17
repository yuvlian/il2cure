package il2cpp

// version-dependent metadata offsets

// defaults prefer the C api accessor (il2cpp_field_get_offset, il2cpp_image_get_name)
// over raw offset reads; only the native method VA and the class byval_arg type
// pointer commonly need raw offsets.

// a mod targeting an obfuscated or version-shifted game builds its own Offsets
// and passes it to the accessor

Offsets :: struct {
	// class_byval_arg: offset of the Il2CppType* (byval_arg)
	// inside the class. UNVERIFIED default.
	class_byval_arg: uintptr,
	// method_va: offset of native fn addr inside MethodInfo.
	method_va:       uintptr,
	// field_offset/image_name: 0 means "use the C api accessor" instead of
	// a raw read (safer across versions)
	field_offset:    uintptr,
	image_name:      uintptr,
}

default_offsets :: proc () -> Offsets {
	return Offsets {
		class_byval_arg = 0xB8,
		method_va       = 8,
		field_offset    = 0,
		image_name      = 0,
	}
}

method_native_address :: proc {
	method_native_address_raw,
	method_native_address_default,
}

method_native_address_raw :: proc (method: Il2CppMethod, offsets: Offsets) -> uintptr {
	if method == 0 {
		return 0
	}
	return (^uintptr)(uintptr(method) + offsets.method_va)^
}

method_native_address_default :: proc (method: Il2CppMethod) -> uintptr {
	return method_native_address_raw(method, default_offsets())
}

class_byval_arg_type :: proc {
	class_byval_arg_type_raw,
	class_byval_arg_type_default,
}

class_byval_arg_type_raw :: proc (class: Il2CppClass, offsets: Offsets) -> Il2CppType {
	if class == 0 || offsets.class_byval_arg == 0 {
		return 0
	}
	return Il2CppType((^uintptr)(uintptr(class) + offsets.class_byval_arg)^)
}

class_byval_arg_type_default :: proc (class: Il2CppClass) -> Il2CppType {
	return class_byval_arg_type_raw(class, default_offsets())
}

field_offset :: proc {
	field_offset_raw,
	field_offset_default,
}

field_offset_raw :: proc (field: Il2CppField, offsets: Offsets) -> uintptr {
	if offsets.field_offset != 0 && field != 0 {
		return (^uintptr)(uintptr(field) + offsets.field_offset)^
	}
	return vm_il2cpp_field_get_offset(field)
}

field_offset_default :: proc (field: Il2CppField) -> uintptr {
	return field_offset_raw(field, default_offsets())
}

image_name :: proc {
	image_name_raw,
	image_name_default,
}

image_name_raw :: proc (image: Il2CppImage, offsets: Offsets) -> cstring {
	if offsets.image_name != 0 && image != 0 {
		return (^cstring)(uintptr(image) + offsets.image_name)^
	}
	return vm_il2cpp_image_get_name(image)
}

image_name_default :: proc (image: Il2CppImage) -> cstring {
	return image_name_raw(image, default_offsets())
}
