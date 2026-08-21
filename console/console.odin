package console

import "core:log"
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

// dont pass log_file if dont want file logging.
// returns [console logger, file logger, multi_logger]
create_loggers :: proc (log_file := "") -> [3]Maybe(log.Logger) {
	console_logger := log.create_console_logger()
	file_logger: Maybe(log.Logger)
	multi_logger: Maybe(log.Logger)

	if log_file != "" {
		if f, ferr := os.open(log_file, {.Write, .Append, .Create}); ferr == nil {
			file_logger = log.create_file_logger(f)
			multi_logger = log.create_multi_logger(console_logger, file_logger.?)
		}
	}

	return {console_logger, file_logger, multi_logger}
}

destroy_loggers :: proc (loggers: [3]Maybe(log.Logger)) {
	#reverse for l, i in loggers {
		if logger, ok := l.?; ok {
			switch i {
			case 0:
				log.destroy_console_logger(logger)
			case 1:
				log.destroy_file_logger(logger)
			case:
				log.destroy_multi_logger(logger)
			}
		}
	}
}

choose_logger :: proc (loggers: [3]Maybe(log.Logger)) -> log.Logger {
	if multi, ok := loggers[2].?; ok {
		return multi
	}
	if console, ok := loggers[0].?; ok {
		return console
	}
	return {}
}
