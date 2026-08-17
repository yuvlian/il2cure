package reflection

import "../il2cpp"

Property_Info :: distinct il2cpp.Il2CppProperty

property_name :: proc (p: Property_Info) -> string {
	return string(il2cpp.vm_il2cpp_property_get_name(il2cpp.Il2CppProperty(p)))
}

// 0 if write only
property_get_method :: proc (p: Property_Info) -> Method_Info {
	return Method_Info(il2cpp.vm_il2cpp_property_get_get_method(il2cpp.Il2CppProperty(p)))
}

// 0 if read-only
property_set_method :: proc (p: Property_Info) -> Method_Info {
	return Method_Info(il2cpp.vm_il2cpp_property_get_set_method(il2cpp.Il2CppProperty(p)))
}

property_attributes :: proc (p: Property_Info) -> Property_Attributes {
	return Property_Attributes(il2cpp.vm_il2cpp_property_get_flags(il2cpp.Il2CppProperty(p)))
}

property_declaring_class :: proc (p: Property_Info) -> il2cpp.Il2CppClass {
	return il2cpp.vm_il2cpp_property_get_parent(il2cpp.Il2CppProperty(p))
}

property_can_read :: proc (p: Property_Info) -> bool {
	return property_get_method(p) != 0
}

property_can_write :: proc (p: Property_Info) -> bool {
	return property_set_method(p) != 0
}

property_is_static :: proc (p: Property_Info) -> bool {
	if m := property_get_method(p); m != 0 {
		return method_is_static(m)
	}
	if m := property_set_method(p); m != 0 {
		return method_is_static(m)
	}
	return false
}
