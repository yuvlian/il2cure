package reflection

import "../il2cpp"

Assembly_Info :: struct {
	handle: il2cpp.Il2CppAssembly,
}

assembly_image :: proc (a: Assembly_Info) -> il2cpp.Il2CppImage {
	return il2cpp.vm_il2cpp_assembly_get_image(a.handle)
}

// returns the image's name, "Assembly-CSharp" for example
image_name :: proc (image: il2cpp.Il2CppImage) -> string {
	return string(il2cpp.vm_il2cpp_image_get_name(image))
}

// returns the image's filename (usually the assembly name)
image_filename :: proc (image: il2cpp.Il2CppImage) -> string {
	return string(il2cpp.vm_il2cpp_image_get_filename(image))
}

// returns the number of classes in the image
image_class_count :: proc (image: il2cpp.Il2CppImage) -> uintptr {
	return il2cpp.vm_il2cpp_image_get_class_count(image)
}

// returns the i-th class of the image
image_class :: proc (image: il2cpp.Il2CppImage, i: uintptr) -> il2cpp.Il2CppClass {
	return il2cpp.vm_il2cpp_image_get_class(image, i)
}

// enumerates every assembly in the runtime domain. returns (assemblies, count)
domain_assemblies :: proc (
	allocator := context.allocator,
) -> ([]il2cpp.Il2CppAssembly, uintptr) {
	domain := il2cpp.vm_il2cpp_domain_get()
	if domain == 0 {
		return nil, 0
	}
	count: uintptr
	asms := il2cpp.vm_il2cpp_domain_get_assemblies(domain, &count)
	if count == 0 {
		return nil, 0
	}
	out := make([]il2cpp.Il2CppAssembly, count, allocator)
	for i in 0 ..< count {
		out[i] = asms[i]
	}
	return out, count
}

// lists every class in an image
assembly_classes :: proc (
	image:       il2cpp.Il2CppImage,
	allocator := context.allocator,
) -> []il2cpp.Il2CppClass {
	n := image_class_count(image)
	out := make([]il2cpp.Il2CppClass, n, allocator)
	for i: uintptr = 0; i < n; i += 1 {
		out[i] = image_class(image, i)
	}
	return out
}

// return image the class belongs to
class_image :: proc (class: il2cpp.Il2CppClass) -> il2cpp.Il2CppImage {
	return il2cpp.vm_il2cpp_class_get_image(class)
}
