package il2cpp

// returns the runtime class of a managed object
typeof :: proc (obj: Il2CppObject) -> Il2CppClass {
	return vm_il2cpp_object_get_class(obj)
}

// returns the type descriptor of class
type_of_class :: proc (class: Il2CppClass) -> Il2CppType {
	return vm_il2cpp_class_get_type(class)
}

// resolves the class of a type descriptor
type_class :: proc (t: Il2CppType) -> Il2CppClass {
	return vm_il2cpp_type_get_class_or_element_class(t)
}

// returns the short name of class (e.g. "List`1")
class_name :: proc (class: Il2CppClass) -> string {
	return string(vm_il2cpp_class_get_name(class))
}

// returns the namespace of class (empty if global)
class_namespace :: proc (class: Il2CppClass) -> string {
	return string(vm_il2cpp_class_get_namespace(class))
}

// returns the immediate base class of class (0 for object)
class_parent :: proc (class: Il2CppClass) -> Il2CppClass {
	return vm_il2cpp_class_get_parent(class)
}

// reports whether class is `base` or derives from it
is_a :: proc (class, base: Il2CppClass) -> bool {
	for k := class; k != 0; k = class_parent(k) {
		if k == base {
			return true
		}
	}
	return false
}

// is abstract?
class_is_abstract :: proc (class: Il2CppClass) -> bool {
	return vm_il2cpp_class_is_abstract(class)
}
