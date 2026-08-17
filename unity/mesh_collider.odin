package unity

import "../il2cpp"

MeshCollider :: distinct il2cpp.Il2CppObject

mesh_collider_ctor :: proc (mc: MeshCollider) -> bool {
	_, ok := invoke_named(il2cpp.Il2CppObject(mc), "UnityEngine.MeshCollider", ".ctor")
	return ok
}

mesh_collider_as_collider :: proc (mc: MeshCollider) -> Collider {
	return Collider(mc)
}