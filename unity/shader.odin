package unity

import "../il2cpp"

Shader :: distinct il2cpp.Il2CppObject

shader_find :: proc (shader: il2cpp.Il2CppString) -> (Shader, bool) {
	s := shader
	res, ok := invoke_named(
		0,
		"UnityEngine.Shader",
		"Find",
		[]string {"System.String"},
		[]uintptr {uintptr(&s)},
	)
	return Shader(res), ok && res != 0
}