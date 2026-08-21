package scan

import "core:sys/windows"

// IMAGE_SECTION_HEADER is not in core:sys/windows
IMAGE_SECTION_HEADER :: struct #packed {
	name:                   [8]byte,
	virtual_size:           u32,
	virtual_address:        u32,
	size_of_raw_data:       u32,
	pointer_to_raw_data:    u32,
	pointer_to_relocations: u32,
	pointer_to_linenumbers: u32,
	number_of_relocations:  u16,
	number_of_linenumbers:  u16,
	characteristics:        u32,
}

Module_Info :: struct {
	base:   uintptr,
	size:   uintptr,
	handle: windows.HMODULE,
}

// IMAGE_IMPORT_DESCRIPTOR / IMAGE_THUNK_DATA / IMAGE_IMPORT_BY_NAME
// are not in core:sys/windows
IMAGE_IMPORT_DESCRIPTOR :: struct #packed {
	original_first_thunk: u32, // RVA of thunk[] (names) or 0
	time_date_stamp:      u32,
	forwarder_chain:      u32,
	name:                 u32, // RVA of imported module name
	first_thunk:          u32, // RVA of thunk[] (bound to their IAT slots)
}

IMAGE_IMPORT_BY_NAME :: struct #packed {
	hint: u16,
	name: [1]byte, // null-terminated ASCII; over-size by name length
}

IMAGE_THUNK_DATA :: struct #packed {
	u1: struct #raw_union {
		function:       uintptr, // AddressOfData / Function (IAT slot)
		ordinal:        uintptr,
		address_of_data: uintptr,
	},
}

IMAGE_ORDINAL_FLAG           :: uintptr(0x8000000000000000)
IMAGE_DIRECTORY_ENTRY_IMPORT :: 1
IMAGE_SCN_MEM_EXECUTE        :: 0x20000000

// returns the RVA of the import directory (0 if none)
module_import_dir :: proc (info: Module_Info) -> uintptr {
	dos := cast(^windows.IMAGE_DOS_HEADER)(rawptr(info.handle))
	nt := cast(^windows.IMAGE_NT_HEADERS64)(info.base + uintptr(dos.e_lfanew))
	return uintptr(nt.OptionalHeader.ImportTable.VirtualAddress)
}

// resolves a loaded module's base address and
// byte span by reading its in-memory PE headers
module_info_from_name :: proc (name: cstring16) -> (Module_Info, bool) {
	handle := windows.GetModuleHandleW(name)
	if rawptr(handle) == nil {
		return Module_Info {}, false
	}

	dos := cast(^windows.IMAGE_DOS_HEADER)(rawptr(handle))
	if dos.e_magic != 0x5A4D {
		return Module_Info {}, false
	}

	nt_offset := uintptr(handle) + uintptr(dos.e_lfanew)
	nt := cast(^windows.IMAGE_NT_HEADERS64)(nt_offset)
	if nt.Signature != 0x00004550 {
		return Module_Info {}, false
	}

	return Module_Info {
		base   = uintptr(handle),
		size   = uintptr(nt.OptionalHeader.SizeOfImage),
		handle = handle,
	}, true
}

// module_section walks the section header array and returns the RVA +
// virtual size of the section matching `name` (e.g. ".text", "il2cpp")
module_section :: proc (
	info: Module_Info,
	name: string,
) -> (rva: uintptr, virtual_size: uintptr, ok: bool) {
	dos := cast(^windows.IMAGE_DOS_HEADER)(rawptr(info.handle))
	nt_offset := info.base + uintptr(dos.e_lfanew)
	nt := cast(^windows.IMAGE_NT_HEADERS64)(nt_offset)

	section_count := int(nt.FileHeader.NumberOfSections)
	sections_offset := nt_offset + size_of(windows.IMAGE_NT_HEADERS64)
	sections := cast([^]IMAGE_SECTION_HEADER)(sections_offset)

	for i in 0 ..< section_count {
		sec := sections[i]
		sec_name := cstring(raw_data(sec.name[:]))
		if string(sec_name) == name {
			return uintptr(sec.virtual_address),
			       uintptr(sec.virtual_size),
			       true
		}
	}

	return 0, 0, false
}

// walks the section header array, calling `visit` with each
// section's RVA, virtual size, and header. `user` is passed through to visit
// as an escape hatch for captured state (anonymous procs capture by value).
// returns false if the PE header can't be read
all_sections :: proc (
	info:  Module_Info,
	visit: proc (
		rva:          uintptr,
		virtual_size: uintptr,
		section:      IMAGE_SECTION_HEADER,
		user:         rawptr,
	) -> bool,
	user:  rawptr = nil,
) -> bool {
	dos := cast(^windows.IMAGE_DOS_HEADER)(rawptr(info.handle))
	nt_offset := info.base + uintptr(dos.e_lfanew)
	nt := cast(^windows.IMAGE_NT_HEADERS64)(nt_offset)

	section_count := int(nt.FileHeader.NumberOfSections)
	sections_offset := nt_offset + size_of(windows.IMAGE_NT_HEADERS64)
	sections := cast([^]IMAGE_SECTION_HEADER)(sections_offset)

	for i in 0 ..< section_count {
		sec := sections[i]
		if !visit(uintptr(sec.virtual_address), uintptr(sec.virtual_size), sec, user) {
			return false
		}
	}
	return true
}
