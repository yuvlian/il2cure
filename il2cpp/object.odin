package il2cpp

import "core:unicode/utf16"

// obj -> class
object_class :: proc (obj: Il2CppObject) -> Il2CppClass {
	return Il2CppClass((^uintptr)(uintptr(obj) + OBJECT_CLASS_OFFSET)^)
}

// returns a new UNITIALIZED managed object of class.
// call vm_il2cpp_runtime_object_init after if the .ctor must run.
object_new :: proc (class: Il2CppClass) -> Il2CppObject {
	return vm_il2cpp_object_new(class)
}

// obj -> T
object_unbox :: proc (obj: Il2CppObject, $T: typeid) -> T {
	return (^T)(uintptr(obj) + OBJECT_BOXED_OFFSET)^
}

// object_box boxes value into a managed object of class
object_box :: proc (class: Il2CppClass, value: $T) -> Il2CppObject {
	return vm_il2cpp_value_box(class, &value)
}

// il2cpp managed string -> utf8, true = ok.
// caller must delete the returned string
string_to_utf8 :: proc (s: Il2CppString, allocator := context.allocator) -> (string, bool) {
	if s == 0 {
		return "", false
	}
	length := i32((^i32)(uintptr(s) + STRING_LENGTH_OFFSET)^)
	chars := ([^]u16)(uintptr(s) + STRING_CHARS_OFFSET)[:length]

	buf := make([]byte, length * 3, allocator)
	n := utf16.decode_to_utf8(buf, chars)
	return string(buf[:n]), true
}

// utf8 -> il2cpp mng string
string_new :: proc (s: string) -> Il2CppString {
	return vm_il2cpp_string_new_len(cstring(raw_data(s)), u32(len(s)))
}

// utf16 -> il2cpp string
string_new_utf16 :: proc (chars: string16) -> Il2CppString {
	return vm_il2cpp_string_new_utf16(raw_data(chars), i32(len(chars)))
}

array_new :: proc (element_class: Il2CppClass, length: uintptr) -> Il2CppArray {
	return vm_il2cpp_array_new(element_class, length)
}

array_length :: proc (arr: Il2CppArray) -> uintptr {
	if arr == 0 { return 0 }
	return (^uintptr)(uintptr(arr) + ARRAY_LENGTH_OFFSET)^
}

// array_elements returns a slice view over the element storage of arr
array_elements :: proc (arr: Il2CppArray, $T: typeid) -> [^]T {
	return ([^]T)(uintptr(arr) + ARRAY_ELEMENTS_OFFSET)
}

array_get :: proc (arr: Il2CppArray, index: uintptr, $T: typeid) -> T {
	return array_elements(arr, T)[index]
}

array_set :: proc (arr: Il2CppArray, index: uintptr, value: $T) {
	array_elements(arr, T)[index] = value
}
