package unity

import "../il2cpp"

application_is_playing :: proc () -> (bool, bool) {
	res, ok := invoke_named(0, "UnityEngine.Application", "get_isPlaying")
	if !ok {
		return false, false
	}
	if res == 0 {
		return false, true
	}
	data := il2cpp.vm_il2cpp_object_unbox(res)
	if data == nil {
		return false, true
	}
	return (^u32)(data)^ != 0, true
}

application_get_target_frame_rate :: proc () -> (f32, bool) {
	res, ok := invoke_named(0, "UnityEngine.Application", "get_targetFrameRate")
	if !ok {
		return 0, false
	}
	return read_value(res, f32)
}

application_set_target_frame_rate :: proc (framerate: i32) -> bool {
	fr := framerate
	_, ok := invoke_named(
		0,
		"UnityEngine.Application",
		"set_targetFrameRate",
		[]string {"System.Int32"},
		[]uintptr {uintptr(&fr)},
	)
	return ok
}