package unity

import "../il2cpp"

Collider :: distinct il2cpp.Il2CppObject

collider_get_enabled :: proc (c: Collider) -> (bool, bool) {
	res, ok := invoke_named(il2cpp.Il2CppObject(c), "UnityEngine.Collider", "get_enabled")
	if !ok {
		return false, false
	}
	return unbox_bool(res), true
}

collider_set_enabled :: proc (c: Collider, value: bool) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Collider",
		"set_enabled",
		[]string {"System.Boolean"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}