package unity

import "../il2cpp"

Image :: distinct il2cpp.Il2CppObject

image_set_sprite :: proc (i: Image, value: Sprite) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(i),
		"UnityEngine.UI.Image",
		"set_sprite",
		[]string {"UnityEngine.Sprite"},
		[]uintptr {uintptr(value)},
	)
	return ok
}