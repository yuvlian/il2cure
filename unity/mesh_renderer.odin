package unity

import "../il2cpp"

MeshRenderer :: distinct il2cpp.Il2CppObject

mesh_renderer_ctor :: proc (mr: MeshRenderer) -> bool {
	_, ok := invoke_named(il2cpp.Il2CppObject(mr), "UnityEngine.MeshRenderer", ".ctor")
	return ok
}

mesh_renderer_as_renderer :: proc (mr: MeshRenderer) -> Renderer {
	return Renderer(mr)
}