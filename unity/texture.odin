package unity

import "../il2cpp"

Texture :: distinct il2cpp.Il2CppObject

texture_ctor :: proc (t: Texture) -> bool {
	_, ok := invoke_named(il2cpp.Il2CppObject(t), "UnityEngine.Texture", ".ctor")
	return ok
}