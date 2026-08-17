package reflection

import "../il2cpp"

Parameter_Info :: struct {
	method: il2cpp.Il2CppMethod,
	index:  u32,
}

parameter_type :: proc (p: Parameter_Info) -> il2cpp.Il2CppType {
	return il2cpp.vm_il2cpp_method_get_param(p.method, p.index)
}

// param name ("" when unnamed)
parameter_name :: proc (p: Parameter_Info) -> string {
	return string(il2cpp.vm_il2cpp_method_get_param_name(p.method, p.index))
}

// is param a: ref/out/in ?
parameter_is_byref :: proc (p: Parameter_Info) -> bool {
	t := parameter_type(p)
	if t == 0 {
		return false
	}
	return il2cpp.vm_il2cpp_type_is_byref(t)
}

// is an out parameter?
//
// il2cpp exposes System.Reflection.ParameterInfo::get_IsOut
// only via the managed ParameterInfo, the C api doesnt.
//
// so this reports false unless the method's parameter name begins with "out_"
parameter_is_out :: proc (p: Parameter_Info) -> bool {
	name := parameter_name(p)
	if len(name) >= 4 && name[:4] == "out_" {
		return true
	}
	return false
}


