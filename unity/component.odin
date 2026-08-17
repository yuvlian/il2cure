package unity

import "../il2cpp"

Component     :: distinct il2cpp.Il2CppObject
MonoBehaviour :: distinct il2cpp.Il2CppObject

component_get_game_object :: proc (c: Component) -> (GameObject, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Component",
		"get_gameObject",
	)
	return GameObject(res), ok && res != 0
}

component_get_transform :: proc (c: Component) -> (Transform, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Component",
		"get_transform",
	)
	return Transform(res), ok && res != 0
}

component_get_tag :: proc (c: Component) -> (il2cpp.Il2CppString, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Component",
		"get_tag",
	)
	return il2cpp.Il2CppString(res), ok && res != 0
}

component_get_name :: proc (c: Component) -> (il2cpp.Il2CppString, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Component",
		"get_name",
	)
	return il2cpp.Il2CppString(res), ok && res != 0
}