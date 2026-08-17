package reflection

import "../il2cpp"

Field_Info :: distinct il2cpp.Il2CppField

field_name :: proc (f: Field_Info) -> string {
	return string(il2cpp.vm_il2cpp_field_get_name(il2cpp.Il2CppField(f)))
}

field_type :: proc (f: Field_Info) -> il2cpp.Il2CppType {
	return il2cpp.vm_il2cpp_field_get_type(il2cpp.Il2CppField(f))
}

field_declaring_class :: proc (f: Field_Info) -> il2cpp.Il2CppClass {
	return il2cpp.vm_il2cpp_field_get_parent(il2cpp.Il2CppField(f))
}

field_offset :: proc (f: Field_Info) -> uintptr {
	return il2cpp.vm_il2cpp_field_get_offset(il2cpp.Il2CppField(f))
}

field_attributes :: proc (f: Field_Info) -> Field_Attributes {
	return Field_Attributes(il2cpp.vm_il2cpp_field_get_flags(il2cpp.Il2CppField(f)))
}

field_is_literal :: proc (f: Field_Info) -> bool {
	return il2cpp.vm_il2cpp_field_is_literal(il2cpp.Il2CppField(f))
}

field_is_static :: proc (f: Field_Info) -> bool {
	return has_flags(field_attributes(f), Field_Attributes_Static)
}

field_is_instance :: proc (f: Field_Info) -> bool {
	return !field_is_static(f) && !field_is_literal(f)
}

field_has_attribute :: proc (f: Field_Info, attr: il2cpp.Il2CppClass) -> bool {
	return il2cpp.vm_il2cpp_field_has_attribute(il2cpp.Il2CppField(f), attr)
}

field_read :: proc (f: Field_Info, obj: il2cpp.Il2CppObject, out: rawptr) {
	il2cpp.vm_il2cpp_field_get_value(obj, il2cpp.Il2CppField(f), out)
}

field_read_static :: proc (f: Field_Info, out: rawptr) {
	il2cpp.vm_il2cpp_field_static_get_value(il2cpp.Il2CppField(f), out)
}

field_write :: proc (f: Field_Info, obj: il2cpp.Il2CppObject, value: rawptr) {
	il2cpp.vm_il2cpp_field_set_value(obj, il2cpp.Il2CppField(f), value)
}

field_write_static :: proc (f: Field_Info, value: rawptr) {
	il2cpp.vm_il2cpp_field_static_set_value(il2cpp.Il2CppField(f), value)
}
