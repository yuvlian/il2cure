package unity

import "../il2cpp"

Transform :: distinct il2cpp.Il2CppObject

// set_position is hot (per-frame), so use the native path
transform_set_position :: proc (t: Transform, pos: Vector3) -> bool {
	m, ok := il2cpp.find_method("UnityEngine.Transform::set_position")
	if !ok {
		return false
	}
	fn := il2cpp.method_proc(
		m,
		proc "c" (il2cpp.Il2CppObject, Vector3, il2cpp.Il2CppMethod),
	)
	if fn == nil {
		return false
	}
	fn(il2cpp.Il2CppObject(t), pos, m)
	return true
}

transform_get_position :: proc (t: Transform) -> (Vector3, bool) {
	res, _ := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"get_position",
	)
	return read_value(res, Vector3)
}

transform_get_rotation :: proc (t: Transform) -> (Quaternion, bool) {
	res, _ := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"get_rotation",
	)
	return read_value(res, Quaternion)
}

transform_get_child_count :: proc (t: Transform) -> (i32, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"get_childCount",
	)
	if !ok {
		return 0, false
	}
	v, ok2 := read_value(res, i32)
	if !ok2 {
		return 0, false
	}
	return v, true
}

transform_set_parent :: proc (t: Transform, parent: Transform) -> bool {
	p := parent
	_, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"SetParent",
		[]string {"UnityEngine.Transform"},
		[]uintptr {uintptr(&p)},
	)
	return ok
}

transform_get_parent :: proc (t: Transform) -> (Transform, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"get_parent",
	)
	return Transform(res), ok && res != 0
}

transform_get_game_object :: proc (t: Transform) -> (GameObject, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"get_gameObject",
	)
	return GameObject(res), ok && res != 0
}

transform_get_local_position :: proc (t: Transform) -> (Vector3, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"get_localPosition",
	)
	if !ok {
		return {}, false
	}
	return read_value(res, Vector3)
}

transform_get_local_scale :: proc (t: Transform) -> (Vector3, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"get_localScale",
	)
	if !ok {
		return {}, false
	}
	return read_value(res, Vector3)
}

transform_get_local_rotation :: proc (t: Transform) -> (Quaternion, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"get_localRotation",
	)
	if !ok {
		return {}, false
	}
	return read_value(res, Quaternion)
}

transform_get_name :: proc (t: Transform) -> (il2cpp.Il2CppString, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"get_name",
	)
	return il2cpp.Il2CppString(res), ok && res != 0
}

transform_get_child :: proc (t: Transform, index: i32) -> (Transform, bool) {
	i := index
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"GetChild",
		[]string {"System.Int32"},
		[]uintptr {uintptr(&i)},
	)
	return Transform(res), ok && res != 0
}

transform_set_sibling_index :: proc (t: Transform, index: i32) -> bool {
	i := index
	_, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"SetSiblingIndex",
		[]string {"System.Int32"},
		[]uintptr {uintptr(&i)},
	)
	return ok
}

transform_set_local_position :: proc (t: Transform, value: Vector3) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"set_localPosition",
		[]string {"UnityEngine.Vector3"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}

transform_set_local_scale :: proc (t: Transform, value: Vector3) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"set_localScale",
		[]string {"UnityEngine.Vector3"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}

transform_set_rotation :: proc (t: Transform, value: Quaternion) -> bool {
	q := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"set_rotation",
		[]string {"UnityEngine.Quaternion"},
		[]uintptr {uintptr(&q)},
	)
	return ok
}

transform_set_local_rotation :: proc (t: Transform, value: Quaternion) -> bool {
	q := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Transform",
		"set_localRotation",
		[]string {"UnityEngine.Quaternion"},
		[]uintptr {uintptr(&q)},
	)
	return ok
}