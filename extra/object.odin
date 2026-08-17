package extra

import "../il2cpp"

object_create :: proc (
	class:    il2cpp.Il2CppClass,
	resolver: il2cpp.Api_Resolver = nil,
) -> il2cpp.Il2CppObject {
	obj := il2cpp.vm_il2cpp_object_new(class)
	if obj == 0 {
		return 0
	}
	il2cpp.vm_il2cpp_runtime_object_init(obj)
	return obj
}
