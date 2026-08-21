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

// ECMA-335 II.23.1.16
Cor_Element_Type :: enum i32 {
	End         = 0x00,
	Void        = 0x01,
	Boolean     = 0x02,
	Char        = 0x03,
	I1          = 0x04,
	U1          = 0x05,
	I2          = 0x06,
	U2          = 0x07,
	I4          = 0x08,
	U4          = 0x09,
	I8          = 0x0a,
	U8          = 0x0b,
	R4          = 0x0c,
	R8          = 0x0d,
	String      = 0x0e,
	Ptr         = 0x0f,
	ByRef       = 0x10,
	ValueType   = 0x11,
	Class       = 0x12,
	Var         = 0x13,
	Array       = 0x14,
	GenericInst = 0x15,
	TypedByRef  = 0x16,
	I           = 0x18,
	U           = 0x19,
	FnPtr       = 0x1b,
	Object      = 0x1c,
	SZArray     = 0x1d,
	MVar        = 0x1e,
	CModReqd    = 0x1f,
	CModOpt     = 0x20,
	Internal    = 0x21,
	Max         = 0x22,
	Modifier    = 0x40,
	Sentinel    = 0x41,
	Pinned      = 0x45,
}
