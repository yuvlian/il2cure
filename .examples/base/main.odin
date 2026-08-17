package main

import "base:runtime"
import "core:fmt"
import "core:thread"
import "../../console"
import "../../extra"
import "../../il2cpp"
import "../../unity"

// the minimal "hello world" il2cure "mod"
// build: odin build .examples/base -build-mode:dll

// the entry point
main :: proc () {
	if runtime.dll_forward_reason == .Process_Attach {
		// we should start our "mod" in a diff thread, though
		thread.create_and_start(mod_thread)
	}
}

mod_thread :: proc () {
	// open our own console window so fmt.print has somewhere to show up
	// title is up to u, it can also be omitted.
	console.init("my_mod") // do note this can return err, handle it if u want.
	defer console.uninit() // this cleans up console stuff on exit

	// for advanced logging (levels, file logging) check ../coverage/main.odin

	fmt.println("hello!!!")

	// block until GameAssembly.dll is actually mapped into the process
	// you can modify how often to check. by default it is every 10ms
	extra.spin_until_ga_load()

	fmt.println("gameassembly is up!")

	// resolve the il2cpp exports
	// by default we use GetProcAddress.
	// for advanced initialization, check ../coverage/main.odin
	if !il2cpp.init() {
		fmt.println("il2cpp.init failed...")
		extra.hang() // hold the thread open so we can read the error
		return
	}

	fmt.println("il2cpp is ready!")

	// your "mod" logic goes here!

	// for now we will just change timescale...
	unity.time_set_time_scale(0.2)
	fmt.println("time is slower by 80% now...")

	// for advanced hooking and whatnot, you can browse source code
	// or check ../coverage/main.odin for a quick browse

	extra.hang() // again, this keeps thread alive
}
