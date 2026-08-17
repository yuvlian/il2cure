package unity

import "../il2cpp"

Camera :: distinct il2cpp.Il2CppObject

camera_get_main :: proc () -> (Camera, bool) {
	res, ok := invoke_named(0, "UnityEngine.Camera", "get_main")
	return Camera(res), ok && res != 0
}

camera_set_active :: proc (c: Camera, active: bool) -> bool {
	e := active
	_, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Camera",
		"set_enabled",
		[]string {"System.Boolean"},
		[]uintptr {uintptr(&e)},
	)
	return ok
}

camera_get_near_clip_plane :: proc (c: Camera) -> (f32, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Camera",
		"get_nearClipPlane",
	)
	if !ok {
		return 0, false
	}
	return read_value(res, f32)
}

camera_get_far_clip_plane :: proc (c: Camera) -> (f32, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Camera",
		"get_farClipPlane",
	)
	if !ok {
		return 0, false
	}
	return read_value(res, f32)
}

camera_get_field_of_view :: proc (c: Camera) -> (f32, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Camera",
		"get_fieldOfView",
	)
	if !ok {
		return 0, false
	}
	return read_value(res, f32)
}

camera_set_near_clip_plane :: proc (c: Camera, value: f32) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Camera",
		"set_nearClipPlane",
		[]string {"System.Single"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}

camera_set_far_clip_plane :: proc (c: Camera, value: f32) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Camera",
		"set_farClipPlane",
		[]string {"System.Single"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}

camera_set_fov :: proc (c: Camera, value: f32) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(c),
		"UnityEngine.Camera",
		"set_fieldOfView",
		[]string {"System.Single"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}