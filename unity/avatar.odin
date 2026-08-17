package unity

import "../il2cpp"

Avatar :: distinct il2cpp.Il2CppObject

avatar_ctor :: proc (a: Avatar) -> bool {
	_, ok := invoke_named(il2cpp.Il2CppObject(a), "UnityEngine.Avatar", ".ctor")
	return ok
}