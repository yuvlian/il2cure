package hook

// basic x86-64 instruction-length decoder

// modrm_len returns the length of the ModRM byte + SIB + displacement
// (not including opcode or immediate) at p (which points to the ModRM byte).
modrm_len :: proc (p: [^]byte) -> uint {
	modrm := p[0]
	mod := modrm >> 6
	rm := modrm & 7
	if mod == 3 {
		return 1 // register-register: just ModRM
	}
	len: uint = 1
	if rm == 4 {
		// SIB byte follows.
		len += 1
		sib := p[1]
		// base == rbp with mod == 0: disp32 after SIB.
		if mod == 0 && (sib & 7) == 5 {
			len += 4
		}
	}
	switch mod {
	case 0:
		if rm == 5 {
			len += 4 // rip-relative disp32
		}
	case 1:
		len += 1 // disp8
	case 2:
		len += 4 // disp32
	}
	return len
}

skip_prefixes :: proc (p: [^]byte) -> (i: uint) {
	for {
		b := p[i]
		switch b {
		case 0x26, 0x2E, 0x36, 0x3E, // segment override
		     0x64, 0x65,             // fs / gs
		     0x66, 0x67,             // operand / address size
		     0xF0,                   // lock
		     0xF2, 0xF3:             // repne / rep
			i += 1
		case:
			return
		}
	}
}

skip_rex :: proc (p: [^]byte) -> (rex_w: bool, i: uint) {
	i = skip_prefixes(p)
	if p[i] >= 0x40 && p[i] <= 0x4F {
		rex_w = (p[i] & 0x08) != 0
		i += 1
	}
	return
}

// instruction len
insn_len :: proc (p: [^]byte) -> uint {
	rex_w, i := skip_rex(p)
	op := p[i]

	// 0x0F: 2 byte opcodes
	if op == 0x0F {
		op2 := p[i + 1]
		switch {
		case op2 == 0x05 || op2 == 0x0B || op2 == 0x0E || op2 == 0x77:
			return i + 2 // syscall, ud2, emms
		case op2 >= 0x80 && op2 <= 0x8F:
			return i + 6 // jcc rel32
		case op2 >= 0xC8 && op2 <= 0xCF:
			return i + 2 // bswap r32/r64
		}
		has_imm8 := (op2 >= 0x70 && op2 <= 0x73) ||
			op2 == 0xA4 || op2 == 0xAC ||
			op2 == 0xBA || op2 == 0xC2 ||
			op2 == 0xC4 || op2 == 0xC5 || op2 == 0xC6
		return i + 2 + modrm_len(p[i + 2:]) + (1 if has_imm8 else 0)
	}

	// 0x00-0x3D: arithmetic groups (ADD/OR/ADC/SBB/AND/SUB/XOR/CMP)
	if op <= 0x3D {
		switch op {
		case 0x06, 0x07, 0x0E, 0x16, 0x17, 0x1E, 0x1F,
		     0x27, 0x2F, 0x37, 0x3F:
			return 0 // invalid in 64-bit mode
		}
		low := op & 7
		if low < 4 {
			return i + 1 + modrm_len(p[i + 1:])
		}
		if low == 4 {
			return i + 2 // AL, imm8
		}
		return i + 5 // eAX, imm32 (sign-extended in 64-bit)
	}

	switch {
	case op >= 0x50 && op <= 0x5F:
		return i + 1 // push/pop r
	case op == 0x63:
		return i + 1 + modrm_len(p[i + 1:]) // movsxd
	case op == 0x68:
		return i + 5 // push imm32
	case op == 0x6A:
		return i + 2 // push imm8
	case op == 0x69:
		return i + 1 + modrm_len(p[i + 1:]) + 4 // imul r,m,imm32
	case op == 0x6B:
		return i + 1 + modrm_len(p[i + 1:]) + 1 // imul r,m,imm8
	case op >= 0x70 && op <= 0x7F:
		return i + 2 // jcc rel8
	case op == 0x80:
		return i + 1 + modrm_len(p[i + 1:]) + 1
	case op == 0x81:
		return i + 1 + modrm_len(p[i + 1:]) + 4
	case op == 0x83:
		return i + 1 + modrm_len(p[i + 1:]) + 1
	case (op >= 0x84 && op <= 0x8B) || op == 0x8D || op == 0x8F:
		return i + 1 + modrm_len(p[i + 1:]) // test/xchg/mov/lea/pop r/m
	case op >= 0x90 && op <= 0x97:
		return i + 1 // nop / xchg r32
	case op >= 0x98 && op <= 0x9F:
		return i + 1 // cbw/cwd/etc
	case op >= 0xA0 && op <= 0xA3:
		return i + 9 // mov r/moffs
	case op >= 0xA4 && op <= 0xA7:
		return i + 1 // movs/cmps
	case op == 0xA8:
		return i + 2 // test al, imm8
	case op == 0xA9:
		return i + 5 // test eax, imm32
	case op >= 0xAA && op <= 0xAF:
		return i + 1 // stos/lods/scas
	case op >= 0xB0 && op <= 0xB7:
		return i + 2 // mov r8, imm8
	case op >= 0xB8 && op <= 0xBF:
		return i + (9 if rex_w else 5) // mov r, imm64/imm32
	case op == 0xC0 || op == 0xC1:
		return i + 1 + modrm_len(p[i + 1:]) + 1 // shift r/m, imm8
	case op == 0xC2:
		return i + 3 // ret imm16
	case op == 0xC3:
		return i + 1 // ret
	case op == 0xC6:
		return i + 1 + modrm_len(p[i + 1:]) + 1 // mov r/m8, imm8
	case op == 0xC7:
		return i + 1 + modrm_len(p[i + 1:]) + 4 // mov r/m32, imm32
	case op == 0xC8:
		return i + 4 // enter
	case op == 0xC9:
		return i + 1 // leave
	case op == 0xCA:
		return i + 3 // retf imm16
	case op == 0xCB, op == 0xCC, op == 0xCF:
		return i + 1 // retf / int3 / iretq
	case op == 0xCD:
		return i + 2 // int imm8
	case op >= 0xD0 && op <= 0xD3:
		return i + 1 + modrm_len(p[i + 1:]) // shift r/m
	case op >= 0xD8 && op <= 0xDF:
		return i + 1 + modrm_len(p[i + 1:]) // x87 (approximate)
	case op >= 0xE0 && op <= 0xE3:
		return i + 2 // loop/jcxz
	case op >= 0xE4 && op <= 0xE7:
		return i + 2 // in/out imm8
	case op == 0xE8 || op == 0xE9:
		return i + 5 // call/jmp rel32
	case op == 0xEB:
		return i + 2 // jmp rel8
	case op >= 0xEC && op <= 0xEF:
		return i + 1 // in/out dx
	case op == 0xF4 || op == 0xF5:
		return i + 1 // hlt / cmc
	case op == 0xF6:
		reg := (p[i + 1] >> 3) & 7
		return i + 1 + modrm_len(p[i + 1:]) + (1 if (reg == 0 || reg == 1) else 0)
	case op == 0xF7:
		reg := (p[i + 1] >> 3) & 7
		return i + 1 + modrm_len(p[i + 1:]) + (4 if (reg == 0 || reg == 1) else 0)
	case op >= 0xF8 && op <= 0xFD:
		return i + 1 // clc/stc/cli/sti/cld/std
	case op == 0xFE:
		return i + 1 + modrm_len(p[i + 1:]) // inc/dec r/m8
	case op == 0xFF:
		return i + 1 + modrm_len(p[i + 1:]) // call/jmp/push r/m
	case:
		return 0 // unknown
	}
}

// returns the offset of a disp32 (within the ModRM sequence)
// if the instruction uses rip-relative addressing, else -1
modrm_rip_disp_offset :: proc (m: [^]byte) -> i32 {
	mod := m[0] >> 6
	rm := m[0] & 7
	if mod != 0 {
		return -1 // base-register or register form
	}
	if rm == 5 {
		return 1 // [rip + disp32]
	}
	if rm == 4 {
		// SIB: base == rbp with mod == 0 → disp32 after SIB.
		sib := m[1]
		if (sib & 7) == 5 {
			return 2
		}
	}
	return -1
}

// returns the byte offset of the disp32 inside the instruction `p`
// if it uses rip-relative addressing, else -1.
rip_rel_disp_offset :: proc (p: [^]byte) -> i32 {
	_, i := skip_rex(p)
	op := p[i]
	modrm_off: i32 = -1

	switch {
	case op == 0x0F:
		op2 := p[i + 1]
		has_modrm := !(op2 == 0x05 || op2 == 0x0B || op2 == 0x0E ||
			op2 == 0x77 || (op2 >= 0x80 && op2 <= 0x8F) || (op2 >= 0xC8 && op2 <= 0xCF))
		if has_modrm {
			modrm_off = i32(i) + 2
		}
	case op <= 0x3D:
		switch op {
		case 0x06, 0x07, 0x0E, 0x16, 0x17, 0x1E, 0x1F,
		     0x27, 0x2F, 0x37, 0x3F:
			return -1 // invalid in 64-bit mode
		}
		low := op & 7
		if low < 4 {
			modrm_off = i32(i) + 1
		}
	case op == 0x63, (op >= 0x84 && op <= 0x8B), op == 0x8D, op == 0x8F,
	     op == 0x69, op == 0x6B, op == 0x80, op == 0x81, op == 0x83,
	     op == 0xC0, op == 0xC1, op == 0xC6, op == 0xC7,
	     (op >= 0xD0 && op <= 0xD3), (op >= 0xD8 && op <= 0xDF),
	     op == 0xF6, op == 0xF7, op == 0xFE, op == 0xFF:
		modrm_off = i32(i) + 1
	}

	if modrm_off < 0 {
		return -1
	}
	disp := modrm_rip_disp_offset(p[modrm_off:])
	if disp < 0 {
		return -1
	}
	return modrm_off + disp
}

// reports whether the displaced bytes capture rsp into a register or write rsp
// such prologues can't be relocated: the trampoline executes them with its own rsp,
// so the resumed code derefs the wrong stack
// (e.g. il2cpp shrink-wrap `mov rax, rsp; mov [rax+10h], rbx`)
prologue_captures_rsp :: proc (p: [^]byte, n: uint) -> bool {
	for i: uint = 0; i + 2 < n; i += 1 {
		if p[i] != 0x48 {
			continue // REX.W prefix
		}
		op := p[i + 1]
		b2 := p[i + 2]
		if op == 0x8B && b2 == 0xC4 {
			return true // mov rax, rsp
		}
		if op == 0x89 {
			switch b2 {
			case 0xE0, 0xC4, 0xE4:
				return true // mov rax/rsp-rsp forms
			}
		}
		// lea reg, [rsp+disp]: ModRM rm=4 -> SIB, SIB base=4 -> rsp.
		if op == 0x8D && (b2 & 7) == 4 && i + 3 < n && (p[i + 3] & 7) == 4 {
			return true
		}
	}
	return false
}
