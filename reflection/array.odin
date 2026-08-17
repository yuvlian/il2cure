package reflection

import "../il2cpp"

array_length :: il2cpp.array_length
array_elements :: il2cpp.array_elements
array_get :: il2cpp.array_get
array_set :: il2cpp.array_set

// element size in bytes for the array's element class
array_element_size :: proc (element_class: il2cpp.Il2CppClass) -> u32 {
	return il2cpp.vm_il2cpp_array_element_size(element_class)
}

// total payload size in bytes
array_byte_length :: proc (a: il2cpp.Il2CppArray) -> u32 {
	return il2cpp.vm_il2cpp_array_get_byte_length(a)
}
