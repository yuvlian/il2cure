package unity

import "../il2cpp"

Object :: distinct il2cpp.Il2CppObject

object_destroy :: proc (obj: il2cpp.Il2CppObject) -> bool {
	_, ok := invoke_named(
		0,
		"UnityEngine.Object",
		"Destroy",
		[]string {"UnityEngine.Object"},
		[]uintptr {uintptr(obj)},
	)
	return ok
}

object_instantiate :: proc (original: il2cpp.Il2CppObject) -> (Object, bool) {
	res, ok := invoke_named(
		0,
		"UnityEngine.Object",
		"Instantiate",
		[]string {"UnityEngine.Object"},
		[]uintptr {uintptr(original)},
	)
	return Object(res), ok && res != 0
}

object_dont_destroy_on_load :: proc (obj: il2cpp.Il2CppObject) -> bool {
	_, ok := invoke_named(
		0,
		"UnityEngine.Object",
		"DontDestroyOnLoad",
		[]string {"UnityEngine.Object"},
		[]uintptr {uintptr(obj)},
	)
	return ok
}