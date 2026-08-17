package unity

import "../il2cpp"

Mesh :: distinct il2cpp.Il2CppObject

mesh_get_vertex_count :: proc (m: Mesh) -> (i32, bool) {
	res, ok := invoke_named(il2cpp.Il2CppObject(m), "UnityEngine.Mesh", "get_vertexCount")
	if !ok {
		return 0, false
	}
	v, ok2 := read_value(res, i32)
	if !ok2 {
		return 0, false
	}
	return v, true
}

mesh_get_vertices :: proc (m: Mesh) -> (il2cpp.Il2CppArray, bool) {
	res, ok := invoke_named(il2cpp.Il2CppObject(m), "UnityEngine.Mesh", "get_vertices")
	return il2cpp.Il2CppArray(res), ok && res != 0
}

mesh_get_normals :: proc (m: Mesh) -> (il2cpp.Il2CppArray, bool) {
	res, ok := invoke_named(il2cpp.Il2CppObject(m), "UnityEngine.Mesh", "get_normals")
	return il2cpp.Il2CppArray(res), ok && res != 0
}

mesh_get_uv :: proc (m: Mesh) -> (il2cpp.Il2CppArray, bool) {
	res, ok := invoke_named(il2cpp.Il2CppObject(m), "UnityEngine.Mesh", "get_uv")
	return il2cpp.Il2CppArray(res), ok && res != 0
}

mesh_get_triangles :: proc (m: Mesh) -> (i32, bool) {
	res, ok := invoke_named(il2cpp.Il2CppObject(m), "UnityEngine.Mesh", "get_triangles")
	if !ok {
		return 0, false
	}
	return read_value(res, i32)
}

mesh_ctor :: proc (m: Mesh) -> bool {
	_, ok := invoke_named(il2cpp.Il2CppObject(m), "UnityEngine.Mesh", ".ctor")
	return ok
}

mesh_set_vertices :: proc (m: Mesh, value: il2cpp.Il2CppArray) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Mesh",
		"set_vertices",
		[]string {"UnityEngine.Vector3[]"},
		[]uintptr {uintptr(value)},
	)
	return ok
}

mesh_set_normals :: proc (m: Mesh, value: il2cpp.Il2CppArray) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Mesh",
		"set_normals",
		[]string {"UnityEngine.Vector3[]"},
		[]uintptr {uintptr(value)},
	)
	return ok
}

mesh_set_uv :: proc (m: Mesh, value: il2cpp.Il2CppArray) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Mesh",
		"set_uv",
		[]string {"UnityEngine.Vector2[]"},
		[]uintptr {uintptr(value)},
	)
	return ok
}

mesh_set_triangles :: proc (m: Mesh, value: il2cpp.Il2CppArray) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Mesh",
		"set_triangles",
		[]string {"System.Int32[]"},
		[]uintptr {uintptr(value)},
	)
	return ok
}

mesh_recalculate_bounds :: proc (m: Mesh) -> bool {
	_, ok := invoke_named(il2cpp.Il2CppObject(m), "UnityEngine.Mesh", "RecalculateBounds")
	return ok
}

mesh_new :: proc () -> (Mesh, bool) {
	class, cok := il2cpp.find_class("UnityEngine.Mesh")
	if !cok {
		return Mesh(0), false
	}
	m := Mesh(il2cpp.object_new(class))
	if m == 0 {
		return Mesh(0), false
	}
	if ok := mesh_ctor(m); !ok {
		return Mesh(0), false
	}
	return m, true
}