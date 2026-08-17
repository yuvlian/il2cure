package unity

import "../il2cpp"

ImageConversion :: distinct il2cpp.Il2CppObject

image_conversion_load_image :: proc (tex: Texture2D, data: il2cpp.Il2CppArray) -> bool {
	_, ok := invoke_named(
		0,
		"UnityEngine.ImageConversion",
		"LoadImage",
		[]string {"UnityEngine.Texture2D", "System.Byte[]"},
		[]uintptr {uintptr(tex), uintptr(data)},
	)
	return ok
}