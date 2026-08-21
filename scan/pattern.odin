package scan

WILDCARD :: max(u16)

find_pattern_in_buffer :: proc (
	buffer:  []byte,
	pattern: []u16,
	base:    uintptr,
) -> (uintptr, bool) {
	n := len(buffer)
	m := len(pattern)

	if m == 0 || n < m {
		return 0, false
	}

	last_concrete: [256]int
	for i in 0 ..< 256 {
		last_concrete[i] = -1
	}

	last_wildcard := -1
	for p in 0 ..< m - 1 {
		b := pattern[p]
		if b == WILDCARD {
			last_wildcard = p
		} else {
			last_concrete[int(byte(b))] = p
		}
	}

	skip: [256]int
	for i in 0 ..< 256 {
		last := last_concrete[i]
		if last_wildcard > last {
			last = last_wildcard
		}

		shift := m - 1 - last
		if shift < 1 {
			shift = 1
		}

		skip[i] = shift
	}

	i := 0
	for i <= n - m {
		matched := true

		for j in 0 ..< m {
			b := pattern[j]
			if b != WILDCARD && buffer[i + j] != byte(b) {
				matched = false
				break
			}
		}

		if matched {
			return base + uintptr(i), true
		}

		i += skip[int(buffer[i + m - 1])]
	}

	return 0, false
}

// find_pattern_in_module scans every executable section of the module
// (.text, and game-specific ones like HSR's "il2cpp"/".upx0") for `pattern`.
// returns the matching VA, or 0/false.
find_pattern_in_module :: proc (
	module:  Module_Info,
	pattern: []u16,
) -> (uintptr, bool) {
	state := struct {
		module:  Module_Info,
		pattern: []u16,
		found:   uintptr,
	}{module, pattern, 0}

	all_sections(
		module,
		proc (
			rva:          uintptr,
			virtual_size: uintptr,
			sec:          IMAGE_SECTION_HEADER,
			user:         rawptr,
		) -> bool {
			st := cast(^struct {
				module:  Module_Info,
				pattern: []u16,
				found:   uintptr,
			})user

			if sec.characteristics & IMAGE_SCN_MEM_EXECUTE == 0 {
				return true
			}

			slice := (cast([^]byte)(st.module.base + rva))[:virtual_size]

			if addr, ok := find_pattern_in_buffer(slice,
				st.pattern, st.module.base + rva); ok {
				st.found = addr
				return false
			}

			return true
		},
		&state,
	)

	return state.found, state.found != 0
}

resolve_call_rel32 :: proc (addr: uintptr) -> uintptr {
	byte_ptr := cast(^byte)(addr)
	if byte_ptr^ != 0xE8 {
		return 0
	}

	disp_ptr := cast(^i32)(addr + 1)
	return addr + 5 + uintptr(disp_ptr^)
}

resolve_lea_rip :: proc (addr: uintptr) -> uintptr {
	bytes := (cast([^]byte)(addr))[:7]

	// REX.W prefix
	if bytes[0] != 0x48 && bytes[0] != 0x4C {
		return 0
	}

	// lea opcode
	if bytes[1] != 0x8D {
		return 0
	}

	// ModRM byte: mod=00, rm=101 (RIP-relative) -> ?? 05
	if (bytes[2] & 0xC7) != 0x05 {
		return 0
	}

	disp_ptr := cast(^i32)(addr + 3)
	return addr + 7 + uintptr(disp_ptr^)
}

resolve_rip_rel :: proc (addr: uintptr) -> uintptr {
	bytes := (cast([^]byte)(addr))[:7]

	// REX.W prefix
	if bytes[0] != 0x48 && bytes[0] != 0x4C {
		return 0
	}

	// 8B = mov r64, [rip+d]; 89 = mov [rip+d], r64; 8D = lea r64, [rip+d]
	if bytes[1] != 0x8B && bytes[1] != 0x89 && bytes[1] != 0x8D {
		return 0
	}

	// ModRM byte: mod=00, rm=101 (RIP-relative) -> ?? 05
	if (bytes[2] & 0xC7) != 0x05 {
		return 0
	}

	disp_ptr := cast(^i32)(addr + 3)
	return addr + 7 + uintptr(disp_ptr^)
}

find_pattern :: proc {find_pattern_in_buffer, find_pattern_in_module}
