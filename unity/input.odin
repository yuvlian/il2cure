package unity

import "../il2cpp"

input_get_axis_raw :: proc (name_value: string) -> (f32, bool) {
	arg := il2cpp.string_new(name_value)
	res, ok := invoke_named(
		0,
		"UnityEngine.Input",
		"GetAxisRaw",
		[]string {"System.String"},
		[]uintptr {uintptr(&arg)},
	)
	if !ok {
		return 0, false
	}
	v, ok2 := read_value(res, f32)
	return v, ok2
}

input_get_key :: proc (key: i32) -> (bool, bool) {
	k := key
	res, ok := invoke_named(
		0,
		"UnityEngine.Input",
		"GetKey",
		[]string {"UnityEngine.KeyCode"},
		[]uintptr {uintptr(&k)},
	)
	if !ok {
		return false, false
	}
	return unbox_bool(res), true
}

input_get_key_down :: proc (key: i32) -> (bool, bool) {
	k := key
	res, ok := invoke_named(
		0,
		"UnityEngine.Input",
		"GetKeyDown",
		[]string {"UnityEngine.KeyCode"},
		[]uintptr {uintptr(&k)},
	)
	if !ok {
		return false, false
	}
	return unbox_bool(res), true
}

input_is_pressed :: proc (key: i32) -> bool {
	b, ok := input_get_key_down(key)
	return ok && b
}

input_is_held :: proc (key: i32) -> bool {
	b, ok := input_get_key(key)
	return ok && b
}