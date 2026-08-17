package hook

import "core:sys/windows"

import "../il2cpp"
import "../scan"

// swaps the MethodInfo->methodPointer slot to detour
write_method_ptr :: proc (
	method: il2cpp.Il2CppMethod,
	detour: rawptr,
) -> rawptr {
	if method == 0 || detour == nil {
		return nil
	}
	slot := rawptr(uintptr(method) + il2cpp.METHOD_POINTER_OFFSET)

	old_prot: windows.DWORD
	if !windows.VirtualProtect(slot, size_of(uintptr), windows.PAGE_READWRITE, &old_prot) {
		return nil
	}

	old := (^rawptr)(slot)^
	(^rawptr)(slot)^ = detour

	restored: windows.DWORD
	windows.VirtualProtect(slot, size_of(uintptr), old_prot, &restored)
	return old
}

hook_method_pointer :: proc (
	method: il2cpp.Il2CppMethod,
	detour: rawptr,
) -> rawptr {
	return write_method_ptr(method, detour)
}

// alloc_trampoline returns a page of executable memory within 2GB of GameAssembly.dll
// (so displaced rip-relative disp32 operands can reach the module),
// bump-allocated from one shared page. Page is VirtualAlloc'd, so gotta use VirtualFree
@(private)
trampoline_page: rawptr

@(private="file")
trampoline_offset: uint = 0

@(private="file")
alloc_trampoline :: proc (size: uint) -> rawptr {
	if trampoline_page == nil {
		ga, ok := scan.module_info_from_name("GameAssembly.dll")
		base := ga.base if ok else uintptr(0)

		hints := []uintptr {
			(base - 0x10000000) if base != 0 else 0,   // 256 MB below
			(base - 0x08000000) if base != 0 else 0,   // 128 MB below
			(base + 0x20000000) if base != 0 else 0,   // 512 MB above
			(base - 0x20000000) if base != 0 else 0,   // 512 MB below
			0,
		}
		for h in hints {
			p := windows.VirtualAlloc(
				rawptr(h),
				4096,
				windows.MEM_COMMIT | windows.MEM_RESERVE,
				windows.PAGE_EXECUTE_READWRITE,
			)
			if p != nil {
				trampoline_page = p
				break
			}
		}
		if trampoline_page == nil {
			return nil
		}
		trampoline_offset = 0
	}
	if trampoline_offset + size > 4096 {
		return nil
	}
	p := rawptr(uintptr(trampoline_page) + uintptr(trampoline_offset))
	trampoline_offset += size
	return p
}

@(private="file")
MAX_INLINE_HOOKS :: 256

@(private="file")
MAX_PROLOGUE :: 32

// ts records one inline-hooked address:
// - the pristine prologue bytes and the cached trampoline shim.
//
// keeping pristine makes re-hooking the same address safe.
// the live body is already our jump, so a re-hook must rebuild from pristine,
// never from the patched bytes.
@(private="file")
Hook_Entry :: struct {
	body:       uintptr,
	trampoline: rawptr,
	pristine:   [MAX_PROLOGUE]byte,
	captured:   uint,
	used:       bool,
}

@(private="file")
inkine_hooks: [MAX_INLINE_HOOKS]Hook_Entry

@(private)
find_inline :: proc (body: uintptr) -> ^Hook_Entry {
	for i in 0 ..< MAX_INLINE_HOOKS {
		if inkine_hooks[i].used && inkine_hooks[i].body == body {
			return &inkine_hooks[i]
		}
	}
	return nil
}

@(private="file")
alloc_inline :: proc (body: uintptr) -> ^Hook_Entry {
	for i in 0 ..< MAX_INLINE_HOOKS {
		if !inkine_hooks[i].used {
			e := &inkine_hooks[i]
			e.body       = body
			e.trampoline = nil
			e.captured   = 0
			e.used       = true
			return e
		}
	}
	return nil
}

// release_inline drops the registration for body and frees the shared
// trampoline page once no inline hook references it anymore
@(private="file")
release_inline :: proc (body: uintptr) {
	for i in 0 ..< MAX_INLINE_HOOKS {
		if inkine_hooks[i].used && inkine_hooks[i].body == body {
			inkine_hooks[i] = Hook_Entry{}
			break
		}
	}

	for i in 0 ..< MAX_INLINE_HOOKS {
		if inkine_hooks[i].used {
			return
		}
	}

	if trampoline_page != nil {
		windows.VirtualFree(trampoline_page, 0, windows.MEM_RELEASE)
		trampoline_page = nil
		trampoline_offset = 0
	}
}

// patch_body writes the jump to detour over the first patch_size bytes of the
// body. Uses a 5-byte E9 rel32 when detour is within 2GB, else a 12-byte
// mov rax,imm64; jmp rax.
@(private="file")
patch_body :: proc (body: uintptr, patch_size: uint, detour: rawptr) -> bool {
	orig := cast([^]byte)(rawptr(body))
	jump := [12]byte {}
	rel := int(uintptr(detour)) - int(body + 5)

	use_rel32 := rel >= int(min(i32)) && rel <= int(max(i32))
	if use_rel32 {
		jump[0] = 0xE9
		(^i32)(rawptr(&jump[1]))^ = i32(rel)
	} else {
		jump[0] = 0x48
		jump[1] = 0xB8
		(^uintptr)(rawptr(&jump[2]))^ = uintptr(detour)
		jump[10] = 0xFF
		jump[11] = 0xE0
	}

	old_prot: windows.DWORD
	if !windows.VirtualProtect(rawptr(body),
		patch_size, windows.PAGE_EXECUTE_READWRITE, &old_prot) {
		return false
	}

	for i: uint = 0; i < patch_size; i += 1 {
		orig[i] = jump[i]
	}

	restored: windows.DWORD
	windows.VirtualProtect(rawptr(body), patch_size, old_prot, &restored)
	return true
}

@(private="file")
build_trampoline :: proc (orig: [^]byte, body: uintptr, captured: uint) -> rawptr {
	tramp_size := captured + 12
	tramp := cast([^]byte)(alloc_trampoline(tramp_size))
	if tramp == nil {
		return nil
	}

	for i: uint = 0; i < captured; i += 1 {
		tramp[i] = orig[i]
	}

	for off: uint = 0; off < captured; {
		disp_off := rip_rel_disp_offset(orig[off:])
		if disp_off >= 0 && uint(disp_off) + 4 <= captured - off {
			delta := int(uintptr(orig) - uintptr(tramp))
			if delta < int(min(i32)) || delta > int(max(i32)) {
				return nil
			}
			(^i32)(rawptr(uintptr(tramp) +
				uintptr(off) + uintptr(disp_off)))^ += i32(delta)
		}
		il := insn_len(orig[off:])
		if il == 0 {
			return nil
		}
		off += il
	}

	tramp[captured + 0] = 0x48
	tramp[captured + 1] = 0xB8
	target := body + uintptr(captured)
	(^uintptr)(rawptr(uintptr(tramp) + uintptr(captured) + 2))^ = target
	tramp[captured + 10] = 0xFF
	tramp[captured + 11] = 0xE0

	return tramp
}

// hook_inline patches the native code body with a jump to the detour and
// overwrites methodPointer, intercepting both direct and dispatched calls.
hook_inline :: proc {
	hook_inline_raw,
	hook_inline_default,
}

hook_inline_raw :: proc (
	method:   il2cpp.Il2CppMethod,
	detour:   rawptr,
	offsets:  il2cpp.Offsets,
) -> (trampoline: rawptr, original: rawptr) {
	if method == 0 || detour == nil {
		return nil, nil
	}

	body := il2cpp.method_native_address_raw(method, offsets)
	if body == 0 {
		return nil, nil
	}
	orig := cast([^]byte)(rawptr(body))

	rel := int(uintptr(detour)) - int(body + 5)
	use_rel32 := rel >= int(min(i32)) && rel <= int(max(i32))
	need := uint(5) if use_rel32 else 12

	if entry := find_inline(body); entry != nil {
		patch_size := min(need, entry.captured)
		original = write_method_ptr(method, detour)
		if original == nil {
			return nil, nil
		}

		if patch_size < need {
			return entry.trampoline, original
		}

		if !patch_body(body, patch_size, detour) {
			write_method_ptr(method, original)
			return nil, nil
		}
		return entry.trampoline, original
	}

	original = write_method_ptr(method, detour)
	if original == nil {
		return nil, nil
	}

	captured: uint = 0
	for captured < need {
		il := insn_len(orig[captured:])
		if il == 0 {
			break
		}
		captured += il
	}

	if captured < need || captured > MAX_PROLOGUE {
		return nil, original
	}

	if prologue_captures_rsp(orig, captured) {
		return nil, original
	}

	tramp := build_trampoline(orig, body, captured)
	if tramp == nil {
		return nil, original
	}

	// register pristine b4 patching
	if e := alloc_inline(body); e == nil {
		return nil, original
	} else {
		for i: uint = 0; i < captured; i += 1 {
			e.pristine[i] = orig[i]
		}
		e.captured = captured
		e.trampoline = tramp
	}

	if !patch_body(body, need, detour) {
		if e := find_inline(body); e != nil {
			e.used = false
		}
		write_method_ptr(method, original)
		return nil, nil
	}

	return tramp, original
}

hook_inline_default :: proc (
	method: il2cpp.Il2CppMethod,
	detour: rawptr,
) -> (trampoline: rawptr, original: rawptr) {
	return hook_inline_raw(method, detour, il2cpp.default_offsets())
}

// hook_iat replaces a module's imported function thunk with the detour.
// returns the original target pointer, or nil if not found
hook_iat :: proc (
	module:        scan.Module_Info,
	import_module: string,
	func_name:     string,
	detour:        rawptr,
) -> (original: rawptr, ok: bool) {
	import_rva := scan.module_import_dir(module)
	if import_rva == 0 {
		return nil, false
	}

	desc := ([^]scan.IMAGE_IMPORT_DESCRIPTOR)(module.base + import_rva)
	for d := 0; desc[d].name != 0; d += 1 {
		mod_name := cstring(rawptr(module.base + uintptr(desc[d].name)))
		if string(mod_name) != import_module {
			continue
		}

		thunk := ([^]scan.IMAGE_THUNK_DATA)(module.base + uintptr(desc[d].first_thunk))
		orig := thunk

		if desc[d].original_first_thunk != 0 {
			orig = ([^]scan.IMAGE_THUNK_DATA)(
				module.base + uintptr(desc[d].original_first_thunk),
			)
		}

		for t := 0; thunk[t].u1.function != 0; t += 1 {
			if orig[t].u1.ordinal & scan.IMAGE_ORDINAL_FLAG == 0 {
				ibn := (^scan.IMAGE_IMPORT_BY_NAME)(
					module.base + uintptr(orig[t].u1.address_of_data),
				)
				ibn_name := cstring(rawptr(uintptr(ibn) + 2))

				if string(ibn_name) == func_name {
					original = rawptr(thunk[t].u1.function)

					old_prot: windows.DWORD
					if !windows.VirtualProtect(
						&thunk[t].u1.function,
						size_of(uintptr),
						windows.PAGE_EXECUTE_READWRITE,
						&old_prot,
					) {
						return nil, false
					}

					thunk[t].u1.function = uintptr(detour)
					restored: windows.DWORD
					windows.VirtualProtect(
						&thunk[t].u1.function,
						size_of(uintptr),
						old_prot,
						&restored,
					)
					return original, true
				}
			}
		}
	}

	return nil, false
}

// hook_iat_all enumerates all loaded modules
hook_iat_all :: proc (
	import_module: string,
	func_name:     string,
	detour:        rawptr,
) -> (original: rawptr, ok: bool) {
	mods: [1024]windows.HMODULE
	needed: windows.DWORD
	if !windows.EnumProcessModules(
		windows.GetCurrentProcess(),
		&mods[0],
		windows.DWORD(size_of(mods)),
		&needed,
	) {
		return nil, false
	}

	count := int(needed) / size_of(windows.HMODULE)

	for i in 0 ..< count {
		h := mods[i]
		name: [260]u16

		n := windows.GetModuleFileNameW(h, &name[0], windows.DWORD(len(name)))
		if n == 0 {
			continue
		}

		info := scan.Module_Info {
			base   = uintptr(h),
			size   = 0, // unused by hook_iat
			handle = h,
		}
	
		if orig, found := hook_iat(info, import_module, func_name, detour); found {
			return orig, true
		}
	}

	return nil, false
}

// uninstall restores a hook. overloads:
// - uninstall(method, original):
//
//    restore the methodPointer slot only
//    (equivalent to the original primitive; for method-pointer hooks).
//
// - uninstall(method, original, offsets):
//
//    restores the pristine body bytes, methodptr slot, and drops the registration
//    (freeing the trampoline page once the last inline hook is removed).
//    `original` may be nil; the pristine state is derived from the registry.
uninstall :: proc {uninstall_slot_only, uninstall_with_offsets}

uninstall_slot_only :: proc (method: il2cpp.Il2CppMethod, original: rawptr) {
	if method == 0 || original == nil {
		return
	}
	write_method_ptr(method, original)
}

uninstall_with_offsets :: proc (
	method:  il2cpp.Il2CppMethod,
	original: rawptr,
	offsets: il2cpp.Offsets,
) {
	if method == 0 {
		return
	}

	body := il2cpp.method_native_address_raw(method, offsets)
	if body == 0 {
		return
	}

	if entry := find_inline(body); entry != nil {
		orig := cast([^]byte)(rawptr(body))
		old_prot: windows.DWORD

		if windows.VirtualProtect(rawptr(body),
			entry.captured, windows.PAGE_EXECUTE_READWRITE, &old_prot) {
			for i: uint = 0; i < entry.captured; i += 1 {
				orig[i] = entry.pristine[i]
			}
			restored: windows.DWORD
			windows.VirtualProtect(rawptr(body), entry.captured, old_prot, &restored)
		}

		write_method_ptr(method, rawptr(body))
		release_inline(body)
		return
	}

	write_method_ptr(method, original)
}

uninstall_all :: proc () {
	for i in 0 ..< MAX_INLINE_HOOKS {
		e := &inkine_hooks[i]
		if !e.used {
			continue
		}

		orig := cast([^]byte)(rawptr(e.body))
		old_prot: windows.DWORD

		if windows.VirtualProtect(rawptr(e.body), e.captured, windows.PAGE_EXECUTE_READWRITE, &old_prot) {
			for j: uint = 0; j < e.captured; j += 1 {
				orig[j] = e.pristine[j]
			}
			restored: windows.DWORD
			windows.VirtualProtect(rawptr(e.body), e.captured, old_prot, &restored)
		}
		inkine_hooks[i] = Hook_Entry{}
	}

	if trampoline_page != nil {
		windows.VirtualFree(trampoline_page, 0, windows.MEM_RELEASE)
		trampoline_page = nil
		trampoline_offset = 0
	}
}

hook_method :: proc {hook_method_inline, hook_method_inline_default}

hook_method_inline :: proc (
	full_class: string,
	method:     string,
	arg_count:  i32,
	detour:     rawptr,
	offsets:    il2cpp.Offsets,
) -> (trampoline: rawptr, original: rawptr) {
	class, ok := il2cpp.find_class(full_class)
	if !ok {
		return nil, nil
	}
	m, mok := il2cpp.class_method(class, method, arg_count)
	if !mok {
		return nil, nil
	}
	return hook_inline(m, detour, offsets)
}

hook_method_inline_default :: proc (
	full_class: string,
	method:     string,
	arg_count:  i32,
	detour:     rawptr,
) -> (trampoline: rawptr, original: rawptr) {
	return hook_method_inline(
		full_class,
		method,
		arg_count,
		detour,
		il2cpp.default_offsets(),
	)
}
