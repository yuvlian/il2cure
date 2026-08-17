package unity

import "../il2cpp"

Sprite :: distinct il2cpp.Il2CppObject

sprite_create :: proc (texture: Texture2D, rect: Rect, pivot: Vector2) -> (Sprite, bool) {
	r := rect
	p := pivot
	res, ok := invoke_named(
		0,
		"UnityEngine.Sprite",
		"Create",
		[]string {"UnityEngine.Texture2D", "UnityEngine.Rect", "UnityEngine.Vector2"},
		[]uintptr {uintptr(texture), uintptr(&r), uintptr(&p)},
	)
	return Sprite(res), ok && res != 0
}