package unity

import "../il2cpp"

MeshFilter :: distinct il2cpp.Il2CppObject

mesh_filter_ctor :: proc (mf: MeshFilter) -> bool {
	_, ok := invoke_named(il2cpp.Il2CppObject(mf), "UnityEngine.MeshFilter", ".ctor")
	return ok
}

mesh_filter_set_mesh :: proc (mf: MeshFilter, mesh: Mesh) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(mf),
		"UnityEngine.MeshFilter",
		"set_mesh",
		[]string {"UnityEngine.Mesh"},
		[]uintptr {uintptr(mesh)},
	)
	return ok
}