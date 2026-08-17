package console

import "core:os"
import "core:sys/windows"

foreign import kernel32 "system:kernel32.lib"

@(default_calling_convention = "stdcall")
foreign kernel32 {
	SetConsoleTitleW :: proc (title: windows.LPCWSTR) -> windows.BOOL ---
}

@(private="file")
console_initted: bool

init :: proc (title: cstring16 = "il2cure") -> (err: os.Error) {
	if console_initted {
		return nil
	}

	if windows.AllocConsole() != windows.TRUE {
		return os.Platform_Error(windows.GetLastError())
	}

	if SetConsoleTitleW(title) != windows.TRUE {
		return os.Platform_Error(windows.GetLastError())
	}

	conout, conout_err := os.open("CONOUT$", {.Write})
	if conout_err != nil {
		return conout_err
	}

	conin, conin_err := os.open("CONIN$", {.Read})
	if conin_err != nil {
		os.close(conout)
		return conin_err
	}

	os.stdout = conout
	os.stderr = conout
	os.stdin = conin

	console_initted = true
	return nil
}

uninit :: proc () {
	if !console_initted {
		return
	}

	if os.stdout != nil {
		os.close(os.stdout)
		os.stdout = {}
		os.stderr = {}
	}
	if os.stdin != nil {
		os.close(os.stdin)
		os.stdin = {}
	}

	windows.FreeConsole()
	console_initted = false
}
