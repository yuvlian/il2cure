package unity

import "../il2cpp"

RenderSettings :: distinct il2cpp.Il2CppObject

render_settings_get_fog :: proc () -> (bool, bool) {
	res, ok := invoke_named(0, "UnityEngine.RenderSettings", "get_fog")
	if !ok {
		return false, false
	}
	return unbox_bool(res), true
}

render_settings_set_fog :: proc (enabled: bool) -> bool {
	e := enabled
	_, ok := invoke_named(
		0,
		"UnityEngine.RenderSettings",
		"set_fog",
		[]string {"System.Boolean"},
		[]uintptr {uintptr(&e)},
	)
	return ok
}