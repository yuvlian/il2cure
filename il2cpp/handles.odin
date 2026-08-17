package il2cpp

Il2CppClass          :: distinct uintptr
Il2CppImage          :: distinct uintptr
Il2CppAssembly       :: distinct uintptr
Il2CppDomain         :: distinct uintptr
Il2CppMethod         :: distinct uintptr  // MethodInfo*
Il2CppField          :: distinct uintptr  // FieldInfo*
Il2CppType           :: distinct uintptr
Il2CppObject         :: distinct uintptr
Il2CppString         :: distinct uintptr
Il2CppArray          :: distinct uintptr
Il2CppThread         :: distinct uintptr
Il2CppException      :: distinct uintptr
Il2CppProperty       :: distinct uintptr  // PropertyInfo*
Il2CppEventInfo      :: distinct uintptr  // EventInfo*
GCHandle             :: distinct u32      // result of il2cpp_gchandle_new
Il2CppStackFrameInfo :: distinct uintptr  // stack frame walk entry

OBJECT_CLASS_OFFSET     :: 0   // *(obj + 0) -> Il2CppClass
OBJECT_BOXED_OFFSET     :: 16  // boxed value payload at obj + 16
STRING_LENGTH_OFFSET    :: 16  // *(str + 16) -> u32 length (utf-16)
STRING_CHARS_OFFSET     :: 20  // str + 20 -> [^]u16 chars
ARRAY_BOUNDS_OFFSET     :: 16  // *(arr + 16) -> bounds (nil for SZArray)
ARRAY_LENGTH_OFFSET     :: 24  // *(arr + 24) -> usize max_length
ARRAY_ELEMENTS_OFFSET   :: 32  // arr + 32 -> first element
METHOD_POINTER_OFFSET   :: 0   // *(method + 0) -> native fn ptr (methodPointer)
METHOD_NAME_OFFSET      :: 8   // *(method + 8) -> cstring name
METHOD_SLOT_OFFSET      :: 46  // *(method + 46) -> u16 slot
CLASS_IMAGE_OFFSET      :: 0   // *(class + 0) -> Il2CppImage

// il2cpp multi-dim array bounds
Array_Bounds :: struct #packed {
	length:      uintptr,
	lower_bound: i32,
	_pad:        [4]byte,
}
