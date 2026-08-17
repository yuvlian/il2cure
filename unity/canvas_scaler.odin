package unity

import "../il2cpp"

CanvasScaler :: distinct il2cpp.Il2CppObject

canvas_scaler_set_ui_scale_mode :: proc (cs: CanvasScaler, mode: i32) -> bool {
	m := mode
	_, ok := invoke_named(
		il2cpp.Il2CppObject(cs),
		"UnityEngine.UI.CanvasScaler",
		"set_uiScaleMode",
		[]string {"UnityEngine.UI.CanvasScaler/ScaleMode"},
		[]uintptr {uintptr(&m)},
	)
	return ok
}

canvas_scaler_set_reference_resolution :: proc (cs: CanvasScaler, value: Vector2) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(cs),
		"UnityEngine.UI.CanvasScaler",
		"set_referenceResolution",
		[]string {"UnityEngine.Vector2"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}