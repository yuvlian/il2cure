package scan

// the il2cpp compiler emits a field gate as one of:
//
//   cmp byte ptr [reg+_isAuto], 0 / jz skip_bake        -> Form 1
//   movzx eax, byte ptr [reg+_isAuto]; test al,al; jz   -> Form 2
//   mov al, byte ptr [reg+_isAuto]; test al,al; jz      -> Form 3
//
// base register varies. disp8 or disp32, no SIB.

// find_gate_jz scans body[0..len) for a `jz rel32` (bytes 0F 84) whose
// [reg+disp] load displacement matches field_off.
// returns the offset of the 0F 84 (the instruction to NOP)
find_gate_jz :: proc(body: [^]u8, len: uint, field_off: u32) -> (jz_off: uint, ok: bool) {
	if body == nil || len < 8 {
		return 0, false
	}
	n := len
	for i := uint(0); i + 8 <= n; i += 1 {
		k := i
		if body[k] >= 0x40 && body[k] <= 0x4F { // optional REX prefix
			k += 1
		}
		if k + 5 >= n {
			break
		}

		// form 1: cmp byte ptr [reg+disp], imm8  (opcode 80, /7, mod 01/10, no SIB)
		if body[k] == 0x80 {
			m := body[k + 1]
			mod := m >> 6
			rm := m & 7
			if (m & 0x38) == 0x38 && mod != 3 && rm != 4 {
				jz: uint
				switch mod {
				case 1: // disp8: 80 7X <disp> 00
					if body[k + 2] == u8(field_off) && body[k + 3] == 0 {
						jz = k + 4
					} else {
						continue
					}
				case: // disp32: 80 BX <disp32> 00
					disp := u32(body[k + 2]) |
						u32(body[k + 3]) << 8 |
						u32(body[k + 4]) << 16 |
						u32(body[k + 5]) << 24
					if disp == field_off && body[k + 6] == 0 {
						jz = k + 7
					} else {
						continue
					}
				}
				if jz + 6 <= n && body[jz] == 0x0F && body[jz + 1] == 0x84 {
					return jz, true
				}
			}
		}

		// form 2: movzx eax, byte ptr [reg+disp] (0F B6); test al,al (84 C0); jz (0F 84)
		if body[k] == 0x0F && body[k + 1] == 0xB6 {
			m := body[k + 2]
			mod := m >> 6
			rm := m & 7
			if (m & 0x38) == 0 && mod != 3 && rm != 4 {
				test_off: uint
				switch mod {
				case 1: // disp8
					if body[k + 3] == u8(field_off) {
						test_off = k + 4
					} else {
						continue
					}
				case: // disp32
					disp := u32(body[k + 3]) |
						u32(body[k + 4]) << 8 |
						u32(body[k + 5]) << 16 |
						u32(body[k + 6]) << 24
					if disp == field_off {
						test_off = k + 7
					} else {
						continue
					}
				}
				if test_off + 8 <= n &&
					body[test_off] == 0x84 && body[test_off + 1] == 0xC0 &&
					body[test_off + 2] == 0x0F && body[test_off + 3] == 0x84 {
					return test_off + 2, true
				}
			}
		}

		// form 3: mov al, byte ptr [reg+disp] (8A); test al,al (84 C0); jz (0F 84)
		if body[k] == 0x8A {
			m := body[k + 1]
			mod := m >> 6
			rm := m & 7
			if (m & 0x38) == 0 && mod != 3 && rm != 4 {
				test_off: uint
				switch mod {
				case 1: // disp8: 8A 4X <disp>
					if body[k + 2] == u8(field_off) {
						test_off = k + 3
					} else {
						continue
					}
				case: // disp32: 8A 8X <disp32>
					disp := u32(body[k + 2]) |
						u32(body[k + 3]) << 8 |
						u32(body[k + 4]) << 16 |
						u32(body[k + 5]) << 24
					if disp == field_off {
						test_off = k + 6
					} else {
						continue
					}
				}
				if test_off + 8 <= n &&
					body[test_off] == 0x84 && body[test_off + 1] == 0xC0 &&
					body[test_off + 2] == 0x0F && body[test_off + 3] == 0x84 {
					return test_off + 2, true
				}
			}
		}
	}
	return 0, false
}

// find_mov_imm32 scans body[start..len) for a `mov r32, imm32` (opcode
// B8..BF) whose 32-bit immediate equals imm.
// returns the offset of the immediate's first byte.
find_mov_imm32 :: proc (
	body:  [^]u8,
	len:   uint,
	start: uint,
	imm:   u32,
) -> (imm_off: uint, ok: bool) {
	if body == nil || len < 5 || start >= len {
		return 0, false
	}
	n := len
	for i := start; i + 5 <= n; i += 1 {
		k := i
		if body[k] >= 0x40 && body[k] <= 0x4F { // REX
			k += 1
		}
		if body[k] >= 0xB8 && body[k] <= 0xBF { // mov r32, imm32
			if body[k + 1] == u8(imm) && body[k + 2] == u8(imm >> 8) &&
				body[k + 3] == u8(imm >> 16) && body[k + 4] == u8(imm >> 24) {
				return k + 1, true
			}
		}
	}
	return 0, false
}
