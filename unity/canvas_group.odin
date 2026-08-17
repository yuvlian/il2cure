package unity

import "../il2cpp"

CanvasGroup :: distinct il2cpp.Il2CppObject

canvas_group_set_alpha :: proc (cg: CanvasGroup, alpha: f32) -> bool {
	a := alpha
	_, ok := invoke_named(
		il2cpp.Il2CppObject(cg),
		"UnityEngine.CanvasGroup",
		"set_alpha",
		[]string {"System.Single"},
		[]uintptr {uintptr(&a)},
	)
	return ok
}

canvas_group_get_alpha :: proc (cg: CanvasGroup) -> (f32, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(cg),
		"UnityEngine.CanvasGroup",
		"get_alpha",
	)
	if !ok {
		return 0, false
	}
	return read_value(res, f32)
}