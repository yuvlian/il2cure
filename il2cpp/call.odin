package il2cpp

method_pointer :: proc (method: Il2CppMethod) -> rawptr {
	if method == 0 {
		return nil
	}
	return (^rawptr)(uintptr(method) + METHOD_POINTER_OFFSET)^
}

// il2cpp compiles managed methods into native functions whose address is
// stored in MethodInfo->methodPointer their native signature is
// `ret(*)(Il2CppObject* this, <params...>, Il2CppMethod* method)``
//
// `this` is null for static methods, and MethodInfo is always the final
// argument. by calling methodptr, we can avoid runtime_invoke's
// reflection and argument marshalling overhead.
//
// method_proc binds a method pointer to a typed Odin signature, allowing
// it to be called like a normal proc:
//
//	   ```
//     m, ok := find_method("UnityEngine.Transform::set_position")
//     set_pos := method_proc(m, proc "c" (Il2CppObject, Vector3, Il2CppMethod))
//     set_pos(transform, vec, m)
//	   ```
//
// for static methods, pass Il2CppObject(0) as `this`.
method_proc :: proc (method: Il2CppMethod, $Sig: typeid) -> Sig {
	ptr := method_pointer(method)
	if ptr == nil {
		return {}
	}

	return cast(Sig)ptr
}
