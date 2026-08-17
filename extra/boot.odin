package extra

import "core:sys/windows"
import "core:time"
import "../scan"

spin_until_module :: proc (
	name: cstring16,
	sleep: time.Duration = 10 * time.Millisecond,
) {
	for {
		if _, ok := scan.module_info_from_name(name); ok {
			break
		}
		time.sleep(sleep)
	}
}

spin_until_ga_load :: proc (sleep: time.Duration = 10 * time.Millisecond) {
	spin_until_module("GameAssembly.dll", sleep)
}

hang :: proc () {
	evt := windows.CreateEventW(nil, true, false, nil)
	if evt == nil {
		for {
			time.sleep(time.Hour)
		}
	}
	defer windows.CloseHandle(evt)
	windows.WaitForSingleObject(evt, windows.INFINITE)
}
