package unity

import "../il2cpp"

RectTransform :: distinct il2cpp.Il2CppObject

rect_transform_get_size_delta :: proc (rt: RectTransform) -> (Vector2, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(rt),
		"UnityEngine.RectTransform",
		"get_sizeDelta",
	)
	if !ok {
		return {}, false
	}
	return read_value(res, Vector2)
}

rect_transform_get_anchored_position :: proc (rt: RectTransform) -> (Vector2, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(rt),
		"UnityEngine.RectTransform",
		"get_anchoredPosition",
	)
	if !ok {
		return {}, false
	}
	return read_value(res, Vector2)
}

rect_transform_set_size_delta :: proc (rt: RectTransform, value: Vector2) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(rt),
		"UnityEngine.RectTransform",
		"set_sizeDelta",
		[]string {"UnityEngine.Vector2"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}

rect_transform_set_anchored_position :: proc (rt: RectTransform, value: Vector2) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(rt),
		"UnityEngine.RectTransform",
		"set_anchoredPosition",
		[]string {"UnityEngine.Vector2"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}

rect_transform_rotate :: proc (rt: RectTransform, axis: Vector3, angle: f32) -> bool {
	a := axis
	ang := angle
	_, ok := invoke_named(
		il2cpp.Il2CppObject(rt),
		"UnityEngine.RectTransform",
		"Rotate",
		[]string {"UnityEngine.Vector3", "System.Single"},
		[]uintptr {uintptr(&a), uintptr(&ang)},
	)
	return ok
}