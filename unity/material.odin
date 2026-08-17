package unity

import "../il2cpp"

Material :: distinct il2cpp.Il2CppObject

material_get_color :: proc (m: Material, prop: string) -> (Color, bool) {
	arg := il2cpp.string_new(prop)
	res, _ := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Material",
		"get_color",
		[]string {"System.String"},
		[]uintptr {uintptr(&arg)},
	)
	return read_value(res, Color)
}

material_set_color :: proc (m: Material, prop: string, col: Color) -> bool {
	arg := il2cpp.string_new(prop)
	c := col
	_, ok := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Material",
		"set_color",
		[]string {"System.String", "UnityEngine.Color"},
		[]uintptr {uintptr(&arg), uintptr(&c)},
	)
	return ok
}

material_ctor :: proc (m: Material, source: Material) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Material",
		".ctor",
		[]string {"UnityEngine.Material"},
		[]uintptr {uintptr(source)},
	)
	return ok
}

material_ctor_shader :: proc (m: Material, shader: Shader) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Material",
		".ctor",
		[]string {"UnityEngine.Shader"},
		[]uintptr {uintptr(shader)},
	)
	return ok
}

material_get_shader :: proc (m: Material) -> (Shader, bool) {
	res, ok := invoke_named(il2cpp.Il2CppObject(m), "UnityEngine.Material", "get_shader")
	return Shader(res), ok && res != 0
}

material_set_shader :: proc (m: Material, shader: Shader) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Material",
		"set_shader",
		[]string {"UnityEngine.Shader"},
		[]uintptr {uintptr(shader)},
	)
	return ok
}

material_set_main_texture :: proc (m: Material, texture: Texture) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(m),
		"UnityEngine.Material",
		"set_mainTexture",
		[]string {"UnityEngine.Texture"},
		[]uintptr {uintptr(texture)},
	)
	return ok
}

material_new_shader :: proc (shader_name: il2cpp.Il2CppString) -> (Material, bool) {
	shader, sok := shader_find(shader_name)
	if !sok {
		return Material(0), false
	}
	class, cok := il2cpp.find_class("UnityEngine.Material")
	if !cok {
		return Material(0), false
	}
	m := Material(il2cpp.object_new(class))
	if m == 0 {
		return Material(0), false
	}
	if ok := material_ctor_shader(m, shader); !ok {
		return Material(0), false
	}
	return m, true
}