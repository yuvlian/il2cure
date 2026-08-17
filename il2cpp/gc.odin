package il2cpp

// sometimes u get gc crash, eg. native callback holds maanaged object
// and then gc collects it, boomboomboom! dis is da solushon
//
// gc_pin roots obj with a strong GCHandle so the gc can't collect it
// while the mod holds it across a native boundary!
//
// returns a handle to pass to gc_free, 0 if fail
gc_pin :: proc (obj: Il2CppObject, pinned: bool = true) -> GCHandle {
	if obj == 0 {
		return 0
	}
	return vm_il2cpp_gchandle_new(obj, pinned)
}

// releases a handle (strong or not) produced by gc_pin
gc_free :: proc (handle: GCHandle) {
	if handle == 0 {
		return
	}
	vm_il2cpp_gchandle_free(handle)
}

// resolves the object a handle currently refers to.
// nil if the object was collected, e.g. a weak handle
gc_target :: proc (handle: GCHandle) -> Il2CppObject {
	if handle == 0 {
		return 0
	}
	return vm_il2cpp_gchandle_get_target(handle)
}

// start full gc cycle
gc_collect :: proc () {
	vm_il2cpp_gc_collect(0)
}
