package hook

import "core:sys/windows"

foreign import kernel32 "system:kernel32.lib"

@(default_calling_convention = "stdcall")
foreign kernel32 {
	FlushInstructionCache :: proc(
		h_process:   windows.HANDLE,
		base_address: windows.LPCVOID,
		size:        windows.SIZE_T,
	) -> windows.BOOL ---
}

// nop_rel32 overwrites the 6-byte `jz/jnz rel32` at body+jz with 0x90 NOPs.
// memory is made RWX for the write and the instruction cache flushed
nop_rel32 :: proc(body: [^]u8, jz: uint) -> bool {
	p := rawptr(uintptr(body) + uintptr(jz))
	old: windows.DWORD
	if !windows.VirtualProtect(p, 6, windows.PAGE_EXECUTE_READWRITE, &old) {
		return false
	}
	for i in uint(0) ..< 6 {
		body[jz + i] = 0x90
	}
	_ = windows.VirtualProtect(p, 6, old, &old)
	return FlushInstructionCache(windows.GetCurrentProcess(), p, 6) == windows.TRUE
}

// patch_byte overwrites one byte of executable memory at body+off with
// value (RWX + I-cache flush). Returns false if the protection change is
// refused. Used to rewrite a constant immediate at its write site.
patch_byte :: proc(body: [^]u8, off: uint, value: u8) -> bool {
	p := rawptr(uintptr(body) + uintptr(off))
	old: windows.DWORD
	if !windows.VirtualProtect(p, 1, windows.PAGE_EXECUTE_READWRITE, &old) {
		return false
	}
	body[off] = value
	_ = windows.VirtualProtect(p, 1, old, &old)
	return FlushInstructionCache(windows.GetCurrentProcess(), p, 1) == windows.TRUE
}

// patch_call rewrites the rel32 of an existing `E8 call rel32` at site to
// point at detour (disabling the original callee when detour is a stub).
// Returns false when site is not a call or detour is out of rel32 range.
patch_call :: proc(site: uintptr, detour: rawptr) -> bool {
	op := (cast(^u8)(site))^
	if op != 0xE8 {
		return false
	}
	dist := int(uintptr(detour)) - int(site + 5)
	if dist < int(min(i32)) || dist > int(max(i32)) {
		return false
	}

	p := rawptr(site + 1)
	old: windows.DWORD
	if !windows.VirtualProtect(p, 4, windows.PAGE_EXECUTE_READWRITE, &old) {
		return false
	}
	(cast(^i32)(site + 1))^ = i32(dist)
	_ = windows.VirtualProtect(p, 4, old, &old)
	return FlushInstructionCache(windows.GetCurrentProcess(), p, 4) == windows.TRUE
}
