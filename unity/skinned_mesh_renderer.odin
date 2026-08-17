package unity

import "../il2cpp"

SkinnedMeshRenderer :: distinct il2cpp.Il2CppObject

skinned_mesh_renderer_get_bones :: proc (smr: SkinnedMeshRenderer) -> (il2cpp.Il2CppArray, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(smr),
		"UnityEngine.SkinnedMeshRenderer",
		"get_bones",
	)
	return il2cpp.Il2CppArray(res), ok && res != 0
}

skinned_mesh_renderer_set_bones :: proc (smr: SkinnedMeshRenderer, bones: il2cpp.Il2CppArray) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(smr),
		"UnityEngine.SkinnedMeshRenderer",
		"set_bones",
		[]string {"UnityEngine.Transform[]"},
		[]uintptr {uintptr(bones)},
	)
	return ok
}