package unity

time_delta_time :: proc () -> f32 {
	res, ok := invoke_named(0, "UnityEngine.Time", "get_deltaTime")
	if !ok {
		return 0
	}
	v, _ := read_value(res, f32)
	return v
}

time_time :: proc () -> f32 {
	res, ok := invoke_named(0, "UnityEngine.Time", "get_time")
	if !ok {
		return 0
	}
	v, _ := read_value(res, f32)
	return v
}

time_get_time_scale :: proc () -> (f32, bool) {
	res, ok := invoke_named(0, "UnityEngine.Time", "get_timescale")
	if !ok {
		return 0, false
	}
	return read_value(res, f32)
}

time_set_time_scale :: proc (time_scale: f32) -> bool {
	ts := time_scale
	_, ok := invoke_named(
		0,
		"UnityEngine.Time",
		"set_timeScale",
		[]string {"System.Single"},
		[]uintptr {uintptr(&ts)},
	)
	return ok
}