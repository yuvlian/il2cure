package unity

import "../il2cpp"

Renderer :: distinct il2cpp.Il2CppObject

renderer_get_material :: proc (r: Renderer) -> (Material, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(r),
		"UnityEngine.Renderer",
		"get_material",
	)
	return Material(res), ok && res != 0
}

renderer_set_enabled :: proc (r: Renderer, enabled: bool) -> bool {
	e := enabled
	_, ok := invoke_named(
		il2cpp.Il2CppObject(r),
		"UnityEngine.Renderer",
		"set_enabled",
		[]string {"System.Boolean"},
		[]uintptr {uintptr(&e)},
	)
	return ok
}

renderer_get_materials :: proc (r: Renderer) -> (il2cpp.Il2CppArray, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(r),
		"UnityEngine.Renderer",
		"get_materials",
	)
	return il2cpp.Il2CppArray(res), ok && res != 0
}

renderer_set_material :: proc (r: Renderer, material: Material) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(r),
		"UnityEngine.Renderer",
		"set_material",
		[]string {"UnityEngine.Material"},
		[]uintptr {uintptr(material)},
	)
	return ok
}

renderer_get_enabled :: proc (r: Renderer) -> (bool, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(r),
		"UnityEngine.Renderer",
		"get_enabled",
	)
	if !ok {
		return false, false
	}
	return unbox_bool(res), true
}