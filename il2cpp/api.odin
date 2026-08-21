package il2cpp

import "core:dynlib"

import "../scan"

Export_Name :: distinct string  // GetProcAddress by canonical name
Obf_Name    :: distinct string  // GetProcAddress by custom obfuscated name
Pattern     :: distinct []u16   // pattern scan
Api_Index   :: distinct u32     // UnityPlayer api-table[index]

// Since not all games have same api, this is to help diff ways to init them
//
// - api("il2cpp_domain_get")                -> normal name (default)
// - api("aobfuscated", Obf_Name("custom"))  -> obfuscated name
// - api("pat", Pattern(SIG))                -> byte-pattern scan
// - api("api_table", Api_Index(7))          -> UnityPlayer api-table (HSR uses this for example)
Api_Resolver :: union {
	Export_Name,
	Obf_Name,
	Pattern,
	Api_Index,
}

// to locate the UnityPlayer il2cpp api-table base pointer:
// - 48 8B 05 ?? ?? ?? ?? 48 8D 0D ?? ?? ?? ?? FF D0
@(private="file")
API_TABLE_SIGNATURE :: []u16 {
	0x48, 0x8B, 0x05, scan.WILDCARD, scan.WILDCARD, scan.WILDCARD, scan.WILDCARD,
	0x48, 0x8D, 0x0D, scan.WILDCARD, scan.WILDCARD, scan.WILDCARD, scan.WILDCARD,
	0xFF, 0xD0,
}

@(private="file")
game_assembly: scan.Module_Info

Resolver_Proc :: #type proc (module: scan.Module_Info, name: string) -> rawptr

// default_export_resolver uses normal name
default_export_resolver :: proc (module: scan.Module_Info, name: string) -> rawptr {
	ptr, ok := dynlib.symbol_address(cast(dynlib.Library)module.handle, name)
	return ptr if ok else nil
}

@(private)
active_resolver: Resolver_Proc = default_export_resolver

resolve_api :: proc (module: scan.Module_Info, resolver: Api_Resolver) -> rawptr {
	switch r in resolver {
	case Export_Name:
		ptr, ok := dynlib.symbol_address(cast(dynlib.Library)module.handle, string(r))
		return ptr if ok else nil
	case Obf_Name:
		ptr, ok := dynlib.symbol_address(cast(dynlib.Library)module.handle, string(r))
		return ptr if ok else nil
	case Pattern:
		addr, ok := scan.find_pattern_in_module(module, ([]u16)(r))
		if !ok {
			return nil
		}
		if target := scan.resolve_call_rel32(addr); target != 0 {
			return rawptr(target)
		}
		if target := scan.resolve_rip_rel(addr); target != 0 {
			return rawptr(target)
		}
		return nil
	case Api_Index:
		up, ok := scan.module_info_from_name("UnityPlayer.dll")
		if !ok {
			return nil
		}
		return resolve_api_table_index(up, module, u32(r))
	}

	return nil
}

resolve_api_table_index :: proc (
	up_module: scan.Module_Info,
	ga_module: scan.Module_Info,
	index:     u32,
) -> rawptr {
	base, ok := scan.find_pattern_in_module(up_module, API_TABLE_SIGNATURE)
	if !ok {
		return nil
	}

	// api-table starts with `48 8B 05 disp32`,
	// we resolve the RIP-relative address at +3 to get the first table entry.
	// each entry is a qword at +i*8
	bytes := (cast([^]byte)(base))[:7]
	if (bytes[0] != 0x48 && bytes[0] != 0x4C) || (bytes[2] & 0xC7) != 0x05 {
		return nil
	}
	table_base := base + 7 + uintptr((cast(^i32)(base + 3))^)

	fn_addr := (cast(^uintptr)(table_base + uintptr(index) * 8))^
	if fn_addr == 0 {
		return nil
	}

	// must be in gameassembly
	if fn_addr < ga_module.base || fn_addr >= ga_module.base + ga_module.size {
		return nil
	}

	return rawptr(fn_addr)
}

@(private="file")
api_cache: map[string]rawptr

@(private="file")
api_skip: map[string]bool

skip_exports :: proc (names: []string) {
	for n in names {
		api_skip[n] = true
	}
}

@(private="file")
resolve_game_assembly :: proc () -> (scan.Module_Info, bool) {
	if game_assembly.base != 0 {
		return game_assembly, true
	}
	m, ok := scan.module_info_from_name("GameAssembly.dll")
	if !ok {
		return {}, false
	}
	game_assembly = m
	return m, true
}

api :: proc (name: string, resolver: Api_Resolver = nil) -> rawptr {
	if api_skip[name] {
		return nil
	}

	module, ok := resolve_game_assembly()
	if !ok {
		return nil
	}

	if p, cached := api_cache[name]; cached {
		return p
	}

	res := resolver
	if res == nil {
		if p := active_resolver(module, name); p != nil {
			api_cache[name] = p
			return p
		}
		res = Export_Name(name)
	}

	p := resolve_api(module, res)
	api_cache[name] = p
	return p
}

// frees the export caches. called by il2cpp.shutdown
@(private)
api_shutdown :: proc () {
	delete(api_cache)
	delete(api_skip)
	game_assembly = {}
}
