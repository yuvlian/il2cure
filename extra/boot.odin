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

@(private="file")
ctrl_c_event: windows.HANDLE

ctrl_c_handler :: proc "system" (dwCtrlType: windows.DWORD) -> windows.BOOL {
	if dwCtrlType == windows.CTRL_C_EVENT {
		windows.SetEvent(ctrl_c_event)
	}
	return true
}

exit_if_ctrl_c :: proc () {
	evt := windows.CreateEventW(nil, true, false, nil)

	if evt == nil {
		windows.SetConsoleCtrlHandler(ctrl_c_handler, true)
		for {
			time.sleep(time.Hour)
		}
	}
	defer windows.CloseHandle(evt)

	ctrl_c_event = evt
	defer ctrl_c_event = nil

	if !windows.SetConsoleCtrlHandler(ctrl_c_handler, true) {
		// no console.
		for {
			time.sleep(time.Hour)
		}
	}
	defer windows.SetConsoleCtrlHandler(ctrl_c_handlerw, false)

	windows.WaitForSingleObject(evt, windows.INFINITE)
}
