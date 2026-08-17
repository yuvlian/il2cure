package unity

import "../il2cpp"

Texture2D :: distinct il2cpp.Il2CppObject

texture_2d_get_width :: proc (t: Texture2D) -> (i32, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Texture2D",
		"get_width",
	)
	if !ok {
		return 0, false
	}
	return read_value(res, i32)
}

texture_2d_get_height :: proc (t: Texture2D) -> (i32, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Texture2D",
		"get_height",
	)
	if !ok {
		return 0, false
	}
	return read_value(res, i32)
}

texture_2d_ctor_w_h :: proc (t: Texture2D, width: i32, height: i32) -> bool {
	w := width
	h := height
	_, ok := invoke_named(
		il2cpp.Il2CppObject(t),
		"UnityEngine.Texture2D",
		".ctor",
		[]string {"System.Int32", "System.Int32"},
		[]uintptr {uintptr(&w), uintptr(&h)},
	)
	return ok
}

texture_2d_new :: proc (width: i32, height: i32) -> (Texture2D, bool) {
	class, cok := il2cpp.find_class("UnityEngine.Texture2D")
	if !cok {
		return Texture2D(0), false
	}
	t := Texture2D(il2cpp.object_new(class))
	if t == 0 {
		return Texture2D(0), false
	}
	if ok := texture_2d_ctor_w_h(t, width, height); !ok {
		return Texture2D(0), false
	}
	return t, true
}

texture_2d_as_texture :: proc (t: Texture2D) -> Texture {
	return Texture(t)
}