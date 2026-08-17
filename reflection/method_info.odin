package reflection

import "../il2cpp"

Method_Info :: distinct il2cpp.Il2CppMethod

method_name :: proc (m: Method_Info) -> string {
	return string(il2cpp.vm_il2cpp_method_get_name(il2cpp.Il2CppMethod(m)))
}

method_return_type :: proc (m: Method_Info) -> il2cpp.Il2CppType {
	return il2cpp.vm_il2cpp_method_get_return_type(il2cpp.Il2CppMethod(m))
}

method_attributes :: proc (m: Method_Info) -> Method_Attributes {
	return Method_Attributes(
		il2cpp.vm_il2cpp_method_get_flags(il2cpp.Il2CppMethod(m), nil))
}

method_declaring_class :: proc (m: Method_Info) -> il2cpp.Il2CppClass {
	return il2cpp.vm_il2cpp_method_get_class(il2cpp.Il2CppMethod(m))
}

method_param_count :: proc (m: Method_Info) -> u32 {
	return il2cpp.vm_il2cpp_method_get_param_count(il2cpp.Il2CppMethod(m))
}

method_param_type :: proc (m: Method_Info, i: u32) -> il2cpp.Il2CppType {
	return il2cpp.vm_il2cpp_method_get_param(il2cpp.Il2CppMethod(m), i)
}

method_param_name :: proc (m: Method_Info, i: u32) -> string {
	return string(il2cpp.vm_il2cpp_method_get_param_name(il2cpp.Il2CppMethod(m), i))
}

method_is_generic :: proc (m: Method_Info) -> bool {
	return il2cpp.vm_il2cpp_method_is_generic(il2cpp.Il2CppMethod(m))
}

method_is_inflated :: proc (m: Method_Info) -> bool {
	return il2cpp.vm_il2cpp_method_is_inflated(il2cpp.Il2CppMethod(m))
}

method_is_static :: proc (m: Method_Info) -> bool {
	return has_flags(method_attributes(m), Method_Attributes_Static)
}

method_is_virtual :: proc (m: Method_Info) -> bool {
	return has_flags(method_attributes(m), Method_Attributes_Virtual)
}

method_is_abstract :: proc (m: Method_Info) -> bool {
	return has_flags(method_attributes(m), Method_Attributes_Abstract)
}

method_has_attribute :: proc (m: Method_Info, attr: il2cpp.Il2CppClass) -> bool {
	return il2cpp.vm_il2cpp_method_has_attribute(il2cpp.Il2CppMethod(m), attr)
}

method_parameters :: proc (m: Method_Info, allocator := context.allocator) -> []Parameter_Info {
	n := method_param_count(m)
	out := make([]Parameter_Info, n, allocator)
	for i: u32 = 0; i < n; i += 1 {
		out[i] = Parameter_Info { method = il2cpp.Il2CppMethod(m), index = i }
	}
	return out
}
