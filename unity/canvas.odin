package unity

import "../il2cpp"

Canvas :: distinct il2cpp.Il2CppObject

canvas_set_render_mode :: proc (c: Canvas, mode: i32) -> bool {
	m := mode
	_, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Canvas",
		"set_renderMode",
		[]string {"UnityEngine.RenderMode"},
		[]uintptr {uintptr(&m)},
	)
	return ok
}