package unity

import "../il2cpp"

Animator :: distinct il2cpp.Il2CppObject

animator_get_float :: proc (a: Animator, name_value: string) -> (f32, bool) {
	arg := il2cpp.string_new(name_value)
	res, ok := invoke_named(
		il2cpp.Il2CppObject(a),
		"UnityEngine.Animator",
		"GetFloat",
		[]string {"System.String"},
		[]uintptr {uintptr(&arg)},
	)
	if !ok {
		return 0, false
	}
	v, ok2 := read_value(res, f32)
	return v, ok2
}

animator_set_bool :: proc (a: Animator, name_value: string, value: bool) -> bool {
	arg := il2cpp.string_new(name_value)
	e := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(a),
		"UnityEngine.Animator",
		"SetBool",
		[]string {"System.String", "System.Boolean"},
		[]uintptr {uintptr(&arg), uintptr(&e)},
	)
	return ok
}

animator_get_avatar :: proc (a: Animator) -> (Avatar, bool) {
	res, ok := invoke_named(il2cpp.Il2CppObject(a), "UnityEngine.Animator", "get_avatar")
	return Avatar(res), ok && res != 0
}

animator_ctor :: proc (a: Animator) -> bool {
	_, ok := invoke_named(il2cpp.Il2CppObject(a), "UnityEngine.Animator", ".ctor")
	return ok
}

animator_set_avatar :: proc (a: Animator, avatar: Avatar) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(a),
		"UnityEngine.Animator",
		"set_avatar",
		[]string {"UnityEngine.Avatar"},
		[]uintptr {uintptr(avatar)},
	)
	return ok
}

animator_set_speed :: proc (a: Animator, value: f32) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(a),
		"UnityEngine.Animator",
		"set_speed",
		[]string {"System.Single"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}