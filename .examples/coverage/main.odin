package main

import "base:runtime"
import "core:encoding/json"
import "core:log"
import "core:os"
import "core:reflect"
import "core:strings"
import "core:thread"
import "core:time"

import "../../console"
import "../../extra"
import "../../hook"
import "../../il2cpp"
import "../../reflection"
import "../../scan"
import "../../unity"

// coverage: a fake "mod" that tries to use everything in this project
//           while explaining stuff briefly, this probably sucks ass tbh...
// build: odin build .examples/coverage -build-mode:dll

// example config struct, default setup, and loader
Config :: struct {
	wait_ga: bool,          // block until gameassembly.dll is mapped in
	poll:    time.Duration, // how often to poll while waiting
	cov:     bool,          // run the game-dependent walk once the bridge is up
}

// our default config, a sane fallback for the loader below
cov_defaults := Config {wait_ga = true, poll = 2 * time.Millisecond, cov = true}

// we can put default for the 2nd arg so we can omit it later!
cov_config_load :: proc (path: string, d := cov_defaults) -> Config {
	// slurp the whole json file into memory (default allocator owns it)
	data, err := os.read_entire_file_from_path(path, context.allocator) // read the file
	if err != nil {
		return d // no file? just hand back the defaults
	}
	defer delete(data) // we own those bytes, free them when we return
	// start from the defaults, let the file override whatever it has
	c := d
	// json parsed fine but left poll <= 0? keep our sane default poll
	if json.unmarshal(data, &c) == nil && c.poll <= 0 { // parse json into our c
		c.poll = d.poll
	}
	return c
}

// this is just to showcase resolver, as you will see later!
USE_DISPATCHER :: false

// main is the DLL entry point
// attach -> spawn thread and forget
main :: proc () {
	// Process_Attach = our dll just got loaded/injected into the game
	if runtime.dll_forward_reason == .Process_Attach { // only run on attach
		// do the real work on our own thread so we don't block the game
		thread.create_and_start(mod_thread) // spawn the mod loop
	}
}

mod_thread :: proc () {
	// odin's builtin logger stuff
	console_logger := log.create_console_logger()       // u can modify this further i believe, i just dont care.
	defer log.destroy_console_logger(console_logger)    // free it when this proc exits

	// we always have the console logger; the file logger is the optional one
	logger := console_logger
	file_logger: log.Logger                            // zero-value until we open the file below
	multi_logger := false                              // did we manage to create the file logger?

	// try to open/create coverage.log next to our dll
	f, ferr := os.open("coverage.log", {.Write, .Append, .Create})
	if ferr == nil {                                   // file opened ok
		file_logger = log.create_file_logger(f)        // wrap the file handle in a logger
		logger = log.create_multi_logger(console_logger, file_logger) // one call -> console AND file
		multi_logger = true
	}

	// "defer if <cond>" only cleans up what we actually created above.
	// if the file logger never got made we skip this, since destroying a
	// logger that was never created would just be trouble
	defer if multi_logger {
		log.destroy_file_logger(file_logger) // free the file logger
		log.destroy_multi_logger(logger)     // free the chained logger
	}

	context.logger = logger // every log.* call below now uses console + file

	// init console with ur custom title!
	if err := console.init("my_console"); err != nil {
		log.warnf("[coverage] no console (file log only)") // console failed, keep going
	}
	defer console.uninit() // clean up the console on exit

	cfg := cov_config_load("coverage.json") // load config (defaults if missing)

	if cfg.wait_ga {
		extra.spin_until_ga_load(cfg.poll) // poll until gameassembly.dll is mapped in
	} else if _, ok := scan.module_info_from_name("GameAssembly.dll"); !ok { // GA not loaded?
		log.warnf("[coverage] GameAssembly.dll not mapped, skipping game walk") // warn, don't crash
		cov_pure_only()            // this just prints~
		extra.hang()               // keeps our dll thread alive so it doesn't just close
		return // exit since we dont have gameassembly to proceed with rest...
	}

	cov_resolver() // init il2cpp (several ways, see below)

	// check if il2cpp is initialized just to be safe...
	if il2cpp.is_initialized() {
		classes, methods := il2cpp.map_stats() // how much il2cpp we can see
		log.infof("[coverage] bridge up: %d classes, %d methods", classes, methods) // confirm bridge
		if cfg.cov {
			cov_core_runtime() // the game walk: find class+method, run every surface
		}
	}

	cov_pure_extra()       // formatting/helper package (names, accessors, modifiers)
	cov_pure_scan()        // signature + address resolution against mapped modules
	cov_reflection_atoms() // pure attribute bit-flag checks
	cov_format()           // log.infof formatting a helper's return value directly
	cov_frame()            // reflection-based field mapping (struct -> managed object)

	extra.exit_if_ctrl_c() // hold until ctrl+c
	// ctrl+c pressed, clean up
	hook.uninstall_all() // undo any inline hooks we installed
	il2cpp.shutdown()    // free the class/method tables + api cache
}

cov_pure_only :: proc () {
	// nothing here touches the game
	log.infof("[coverage] (pure surfaces still exercised)") // proves the logger works
}

// --- resolver: mixed export resolution (examples/resolver) -----------------

// stripped export -> recover by byte pattern (placeholder). All three
// strategies are dispatched per-export; see examples/resolver for detail.
CLASS_FROM_NAME_SIG :: []u16 {
	0x48, 0x8B, 0x05, scan.WILDCARD, scan.WILDCARD, scan.WILDCARD,
	0xFF, 0xD0,
}

cov_resolver :: proc () {
	if USE_DISPATCHER {
		// this uses a custom dispatcher,
		// see cov_dispatcher_resolver below
		if !il2cpp.init(cov_dispatcher_resolver) { // init with our custom resolver
			log.errorf("[coverage] il2cpp.init (dispatcher) failed") // uhoh! our custom resolver failed...
		}
	} else {
		// this we use different api resolvers
		// we have pattern which u can give a signature to be scanned for
		// obfuscated name, for example limbus would use this
		// api index, for example HSR would use this
		// and by default use normal api resolver which is GetProcAddress
		resolvers := make(map[string]il2cpp.Api_Resolver) // map of il2cpp api name to the resolver
		defer delete(resolvers)

		resolvers[il2cpp.IL2CPP_CLASS_FROM_NAME] = il2cpp.Pattern(CLASS_FROM_NAME_SIG)       // pattern sig
		resolvers[il2cpp.IL2CPP_CLASS_GET_NAME]  = il2cpp.Obf_Name("PutRenamedExportHere")   // obfuscated
		resolvers[il2cpp.IL2CPP_RUNTIME_INVOKE]  = il2cpp.Api_Index(17)                      // by export index

		if !il2cpp.init_map(resolvers) {
			log.errorf("[coverage] il2cpp.init_map failed") // oh nyooooooo
		}
	}

	// skip_exports!
	il2cpp.skip_exports([]string {
		il2cpp.IL2CPP_CLASS_GET_TYPE,
		il2cpp.IL2CPP_CLASS_IS_VALUETYPE,
	})
	assert(il2cpp.api("il2cpp_class_get_type") == nil, "skipped export must resolve nil") // skipped
	assert(il2cpp.api("il2cpp_class_is_valuetype") == nil, "skipped export must resolve nil") // skipped
}

cov_dispatcher_resolver :: proc (m: scan.Module_Info, name: string) -> rawptr {
	switch name {
	case "il2cpp_class_from_name":
		// find our signature bytes inside the gameassembly module
		addr, ok := scan.find_pattern_in_module(m, CLASS_FROM_NAME_SIG) // scan for our sig
		if !ok {
			return nil
		}
		// whatever we found could be a `call rel32` or a `lea rip+disp`;
		// resolve whichever form it actually is into a real address
		if p := scan.resolve_call_rel32(addr); p != 0 { // it's a `call rel32`
			return rawptr(p)
		}
		if p := scan.resolve_rip_rel(addr); p != 0 { // it's a `lea/[rip+disp]`
			return rawptr(p)
		}
		return nil
	case "il2cpp_class_get_name":
		// obfuscated name? hand it back to the normal api resolver
		return il2cpp.api("il2cpp_class_get_name", il2cpp.Obf_Name("PutRenamedExportHere"))
	case "il2cpp_runtime_invoke":
		// api-index strategy, same as the primary path up top
		return il2cpp.api("il2cpp_runtime_invoke", il2cpp.Api_Index(17))
	case:
		// anything we didn't special-case -> plain GetProcAddress lookup
		return il2cpp.default_export_resolver(m, name)
	}
}

// --- the game-dependent walk-------------

// this only runs once il2cpp is actually up (see mod_thread), so its safe
// to assume classes/methods will resolve here
cov_core_runtime :: proc () {
	// grab a class we know exists in basically every unity game, this is
	// our anchor for everything below (fields, methods, hooks, etc)
	class, ok := il2cpp.find_class("UnityEngine.GameObject") // our anchor class
	if !ok {
		log.warnf("[coverage] no GameObject class") // no class, bail out safely
		return
	}
	// find a method both direct and by argument count (load-bearing for the
	// lazy write-back: both cache back into the class/method table).
	m, mok := il2cpp.find_method("UnityEngine.GameObject::GetComponent") // method handle
	if !mok {
		log.warnf("[coverage] no GetComponent method") // no method, bail out safely
		return
	}
	// same method again but disambiguated by param count, just to make sure
	// the overload-picking path works too
	_, _ = il2cpp.find_method("UnityEngine.GameObject::GetComponent", 1) // overload by arg count

	// walk each subsystem one at a time... class and m get reused below
	cov_il2cpp_model()                // raw il2cpp bridge
	cov_unity_surface()               // unity wrapper api
	cov_reflection_surface(class, m)  // System.Reflection-style layer
	cov_hook_surface(m)               // set up detour hooks
}

// exercises the raw il2cpp bridge itself. strings, arrays, dicts, gc
// handles, class/type probes and field access. all of this is safe to call
// with 0/nil handles, it just wont actually move any data
cov_il2cpp_model :: proc () {
	// strings: an untyped literal coerces to string16/cstring16
	if s := il2cpp.string_new_utf16("hello il2cure"); s != 0 { // make a managed utf16 string
		if utf8, uok := il2cpp.string_to_utf8(s); uok { // back to a normal odin string
			log.infof("[coverage] string: %q", utf8) // log round-trip result
			delete(utf8)                             // we own those bytes
		}
	}
	_ = il2cpp.string_new("sample") // utf8 -> managed string (same idea)

	// arrays + dictionary (no-ops without live element types, but the calls
	// are all wired up the way u'd use them for real).
	arr := il2cpp.array_new(0, 4)                      // (element class, length)
	_ = il2cpp.array_length(arr)                       // how many elements
	_ = il2cpp.array_get(arr, 0, il2cpp.Il2CppObject)  // read element at index 0
	il2cpp.array_set(arr, 0, 0)                        // write element at index 0
	_ = il2cpp.dict_count(0)                           // Dictionary.Count
	_ = il2cpp.dict_entries(0)                         // raw entries array

	// gc handles.
	h := il2cpp.gc_pin(0) // this pins our managed obj so it doesnt get GC'd
	il2cpp.gc_target(h) // we can check the gc handle of objs
	il2cpp.gc_free(h) // we can also free them
	il2cpp.gc_collect() // this collects everything except the things we pin

	// class / type probes
	_ = il2cpp.class_name(0)        // "GameObject"
	_ = il2cpp.class_namespace(0)   // "UnityEngine"
	_ = il2cpp.class_parent(0)      // parent class
	_ = il2cpp.class_is_abstract(0) // abstract?

	// field access. the value-based ones move raw bytes (passing nil just
	// no-ops), the *_object / *_string ones for reference-typed fields.
	il2cpp.field_read(0, 0, nil)              // read a field into `value`
	il2cpp.field_write(0, 0, nil)             // write `value` into a field
	_ = il2cpp.field_read_object(0, 0)        // read an object-typed field
	il2cpp.field_write_object(0, 0, 0, 0)     // write an object-typed field
	_, _ = il2cpp.field_read_string(0, 0)     // read a string-typed field
	il2cpp.field_static_read(0, nil)          // read a static field
	il2cpp.field_static_write(0, nil)         // write a static field
	_ = il2cpp.field_static_read_object(0, 0) // read a static object field
	il2cpp.field_static_write_object(0, 0, 0) // write a static object field
	_ = il2cpp.field_offset(0)                // byte offset of the field in the class layout

	_ = il2cpp.image_name(0) // which image/assembly a class lives in

	il2cpp.api("il2cpp_field_get_offset", il2cpp.Api_Index(64)) // resolve field get offset

	// Offsets = a struct of version-dependent byte offsets into il2cpp's
	// internal structs. unity games shove headers around between versions,
	// so instead of hardcoding field positions we store "how many bytes
	// into MethodInfo is the native fn ptr" (method_va), "where the
	// Il2CppType* lives inside Il2CppClass" (class_byval_arg), etc.
	// default_offsets() fills one with sane defaults for a normal build;
	// hook_inline reads method_va to locate the method's real native code
	// and patch a jump to our detour. this call just exercises the surface.
	il2cpp.default_offsets()
}

// i often use these and i no no wanna
// write GameObject/Transform/etc invokes by hand every time
cov_unity_surface :: proc () {
	// pure math + static value helpers, no live object needed at all.
	_ = unity.math_clamp01(1.5)                    // Mathf.Clamp01
	_ = unity.time_delta_time()                    // Time.deltaTime
	_ = unity.time_time()                          // Time.time
	_, _ = unity.input_get_axis_raw("Horizontal") // Input.GetAxisRaw
	_, _ = unity.application_is_playing()         // Application.isPlaying

	// object graph walkers (all safe on a 0 object).
	_ = unity.get_class_of(0)                        // class handle of an object
	_, _ = unity.invoke_named(0, "UnityEngine.GameObject", "get_transform") // invoke by name (cached find_method)
	_, _ = unity.invoke(0, 0, 0, {})               // raw invoke with an arg ptr
	_, _ = unity.read_value(0, f32)                // read a managed value as f32

	// gameobject spawn/lookup + component fetching
	_, _ = unity.game_object_find("Main Camera")             // GameObject.Find
	_, _ = unity.game_object_create("Spawned")               // new GameObject
	_, _ = unity.game_object_get_transform(0)                // .transform
	_, _ = unity.game_object_get_component(0, "UnityEngine.Transform") // .GetComponent<T>
	_, _ = unity.component_get_game_object(0)              // .gameObject
	_, _ = unity.component_get_transform(0)                // .transform

	// transform get/set, position/rotation/parenting
	_, _ = unity.transform_get_position(0)        // .position
	_ = unity.transform_set_position(0, {0, 0, 0}) // .position = ...
	_, _ = unity.transform_get_rotation(0)        // .rotation
	_, _ = unity.transform_get_child_count(0)     // .childCount
	_ = unity.transform_set_parent(0, 0)           // .SetParent(...)

	// material/renderer/canvas helpers, the stuff u'd tweak for visuals
	_, _ = unity.material_get_color(0, "_Color")     // .material.GetColor("_Color")
	_ = unity.material_set_color(0, "_Color", {1, 1, 1, 1}) // .material.SetColor(...)
	_, _ = unity.renderer_get_material(0)            // .GetComponent<Renderer>().material
	_ = unity.renderer_set_enabled(0, true)          // .enabled = true
	_ = unity.canvas_group_set_alpha(0, 0.5)         // CanvasGroup.alpha

	// camera/mesh/animator misc
	_, _ = unity.camera_get_main()              // Camera.main
	_ = unity.camera_set_active(0, true)        // Camera.active = true
	_, _ = unity.mesh_get_vertex_count(0)       // Mesh.vertexCount
	_, _ = unity.animator_get_float(0, "Speed") // Animator.GetFloat("Speed")
	_ = unity.animator_set_bool(0, "Grounded", true) // Animator.SetBool(...)

	// the structural value types. plain odin structs mirroring unity's
	// blittable layout, so u can pass/return them straight from invokes.
	_ = unity.Vector2{1, 2}          // 2D vector
	_ = unity.Vector3{1, 2, 3}       // 3D vector
	_ = unity.Vector4{1, 2, 3, 4}    // 4D vector
	_ = unity.Rect{0, 0, 100, 50}    // axis-aligned rect
	_ = unity.Quaternion{0, 0, 0, 1} // rotation
	_ = unity.Color{1, 1, 1, 1}      // rgba color
}

// this is our "System.Reflection"-style layer; walk assemblies/images,
// list classes, and pull fields/methods/properties off a class the same way
// u would in c#. class and m are the ones found back in cov_core_runtime.
cov_reflection_surface :: proc (
	class: il2cpp.Il2CppClass,
	m:     il2cpp.Il2CppMethod,
) {
	// domain / assembly / image walk.
	assemblies, _ := reflection.domain_assemblies() // every loaded assembly
	defer delete(assemblies)                        // we own the slice
	for a in assemblies {
		// wrap the raw handle so the image helpers below accept it
		img := reflection.assembly_image(reflection.Assembly_Info{handle = a}) // handle -> image
		_ = img
		_ = reflection.image_name(img)        // image's namespace/name
		_ = reflection.image_filename(img)    // on-disk filename
		_ = reflection.image_class_count(img) // how many classes it exports
		n := reflection.image_class_count(img)
		for i: uintptr = 0; i < n && i < 4; i += 1 { // first 4 classes only
			_ = reflection.image_class(img, i) // class at index i
		}
	}

	// class membership + traits.
	_ = reflection.class_image(class)         // which image the class lives in
	_ = reflection.class_is_interface(class)  // interface?
	_ = reflection.class_is_abstract(class)   // abstract?
	_ = reflection.class_is_valuetype(class)  // struct vs class?
	base_types := reflection.class_base_types(class) // base class + interfaces
	interfaces := reflection.class_interfaces(class) // just the interfaces
	defer delete(base_types)
	defer delete(interfaces)
	_ = base_types
	_ = interfaces
	fields := reflection.class_all_fields(class)      // all fields (incl. inherited)
	methods := reflection.class_all_methods(class)    // all methods (incl. inherited)
	props := reflection.class_all_properties(class)   // all properties
	members := reflection.class_members(class)        // every member, unified
	defer delete(fields)
	defer delete(methods)
	defer delete(props)
	defer delete(members)

	// fields.
	for f in fields {
		_ = reflection.field_name(f)           // field name
		_ = reflection.field_type(f)           // field type
		_ = reflection.field_declaring_class(f) // where it's declared
		_ = reflection.field_offset(f)         // byte offset in the class
		_ = reflection.field_attributes(f)     // raw attribute flags
		_ = reflection.field_is_literal(f)     // const?
		_ = reflection.field_is_static(f)      // static?
		_ = reflection.field_is_instance(f)    // instance (non-static)?
	}
	reflection.field_read(0, 0, nil)        // read a managed field by raw offset
	reflection.field_read_static(0, nil)    // read a static field
	reflection.field_write(0, 0, nil)       // write a managed field
	reflection.field_write_static(0, nil)   // write a static field

	// methods.
	mi := reflection.Method_Info(m) // wrap the raw method handle
	_ = reflection.method_name(mi)           // method name
	_ = reflection.method_return_type(mi)    // return type
	_ = reflection.method_attributes(mi)     // raw attribute flags
	_ = reflection.method_declaring_class(mi) // where it's declared
	_ = reflection.method_param_count(mi)    // param count
	_ = reflection.method_is_generic(mi)     // generic method?
	_ = reflection.method_is_inflated(mi)    // generic with concrete args?
	_ = reflection.method_is_static(mi)      // static?
	_ = reflection.method_is_virtual(mi)     // virtual?
	_ = reflection.method_is_abstract(mi)    // abstract?
	_ = reflection.method_has_attribute(mi, 0) // has a specific attribute flag?
	params := reflection.method_parameters(mi)
	defer delete(params)
	for p in params {
		_ = reflection.parameter_type(p)    // param's type
		_ = reflection.parameter_name(p)    // param's name
		_ = reflection.parameter_is_byref(p) // out/ref?
		_ = reflection.parameter_is_out(p)  // out specifically?
	}
	_ = reflection.method_param_type(mi, 0) // type of the 0th param
	_ = reflection.method_param_name(mi, 0) // name of the 0th param
	// checks a method against BindingFlags-style visibility rules, same
	// idea as c#'s reflection api
	_ = reflection.method_visible(m, reflection.Binding_Flags_Default) // visibility check

	// properties.
	for prop in props {
		_ = reflection.property_name(prop)        // property name
		_ = reflection.property_get_method(prop)  // the getter
		_ = reflection.property_set_method(prop)  // the setter
		_ = reflection.property_attributes(prop)  // raw flags
		_ = reflection.property_declaring_class(prop) // where it's declared
		_ = reflection.property_can_read(prop)    // has a getter?
		_ = reflection.property_can_write(prop)   // has a setter?
		_ = reflection.property_is_static(prop)   // static?
	}

	// member-info generic accessors.
	for mem in members {
		_ = reflection.member_name(mem)           // member name
		_ = reflection.member_declaring_class(mem) // where it's declared
		_ = reflection.member_is_static(mem)      // static?
		_ = reflection.member_metadata_token(mem) // the il metadata token
	}

	// runtime type + enums.
	t := reflection.method_return_type(mi) // a method's return type
	_ = reflection.type_il_name(t)         // il name of that type
	_ = reflection.type_is_byref(t)        // is it a ref/out?
	_ = reflection.type_class(t)           // the class behind a type
	_ = reflection.type_attributes(t)      // raw type flags
	if reflection.enum_is_enum(class) {         // is our class an enum?
		_, _ = reflection.enum_underlying_type(class) // the enum's backing type
		_ = reflection.enum_underlying_name(class)    // its il name
		enum_vals := reflection.enum_fields(class)    // the enum's values
		delete(enum_vals)                             // we own the slice
	}

	// reflection overload-resolution helpers. param_type_name gives u the
	// IL type name of a single param without building the whole param list,
	// and find_method_specific_on searches a runtime type for a named
	// method (handy when u only have a System.Type, not a class handle).
	_ = reflection.param_type_name(m, 0) // il type name of param 0 (managed view)
	rt := reflection.runtime_type_of_class(class)    // the System.Type for a class
	_, _ = reflection.find_method_specific_on(rt, "Nope") // find a method on that type
}

// --- hooks (pure decoders always; hook_inline only once a method exists) ----

// hook.hook_inline does the actual detouring; everything above that call is
// just the x86-64 instruction decoder it uses internally to figure out how
// many bytes of the prologue it can safely steal for the trampoline
cov_hook_surface :: proc (m: il2cpp.Il2CppMethod) {
	// instruction decoders run on any bytes, don't need a live method for
	// these, we just fake a `mov rax, [rip+X]` opcode to decode.
	buf: [16]byte
	buf[0], buf[1], buf[2] = 0x48, 0x8B, 0x05 // fake `mov rax,[rip+..]` prologue
	_ = hook.skip_prefixes(raw_data(buf[:]))      // skip legacy prefix bytes
	_, _ = hook.skip_rex(raw_data(buf[:]))        // skip the REX byte if present
	_ = hook.modrm_len(raw_data(buf[:]))          // how many bytes the modrm+sib+disp take
	_ = hook.insn_len(raw_data(buf[:]))           // total instruction length
	_ = hook.modrm_rip_disp_offset(raw_data(buf[:]))  // where the rip-rel disp32 starts
	_ = hook.rip_rel_disp_offset(raw_data(buf[:]))    // same but for a plain lea/call form
	_ = hook.prologue_captures_rsp(raw_data(buf[:]), 16) // does the prologue touch rsp?

	// live inline hook. restored by hook.uninstall_all() in mod_thread.
	// there are also other ways to unregister a hook and such. browse the source code~
	tramp, orig := hook.hook_inline(m, rawptr(cov_detour), il2cpp.default_offsets()) // do the detour
	_, _ = tramp, orig // trampoline + original bytes; we don't need them here

	// hook_inline_address: bare native address (no Il2CppMethod), as a scan result would give.
	addr := il2cpp.method_native_address_default(m) // raw uintptr native body
	tramp_addr, aok := hook.hook_inline_address(addr, rawptr(cov_detour))
	_, _ = tramp_addr, aok
}

// the detour target swapped in place of GetComponent above. it needs the
// "c" calling convention since that's what il2cpp/unity expects. left empty
// on purpose, this coverage mod just proves install/uninstall works, it
// doesn't actually need to do anything when the hook fires.
cov_detour :: proc "c" () {
}

// --- pure / data-only surfaces ----------------------------------------------

// "extra" is our formatting/helper package. turns raw il2cpp metadata into
// readable strings, kinda like a mini ilspy/dnspy. all of it is pure and
// safe to call with class/method/field handles == 0, they just come back
// empty instead of crashing.
cov_pure_extra :: proc () {
	// metadata names on a 0 class: empty, not a fault.
	cfn := extra.class_full_name(0)  // "Namespace.Class"
	delete(cfn)                      // we own those bytes
	_ = extra.class_kind_suffix(0)   // " (generic)"/" (inflated)" for classes
	_ = extra.method_kind_suffix(0)  // same idea but for methods

	// format renderers (pure string builders).
	_ = extra.type_format_name(0, true)      // C#-ish type name
	mpl := extra.method_param_list(0, 0) // "int, string" param list
	defer delete(mpl)
	// access/modifier renderers: c#-style "public"/"static"/etc strings,
	// built off the raw attribute bitflags from reflection
	_ = extra.field_access(reflection.Field_Attributes_Public)      // "public" etc
	_ = extra.field_modifier(reflection.Field_Attributes_Public)    // "static" etc
	_ = extra.field_modifier_str(reflection.Field_Info{})           // same, from a Field_Info
	_ = extra.method_access(reflection.Method_Attributes_Public)    // "public" etc
	_ = extra.method_modifier(reflection.Method_Attributes_Public)  // "static virtual" etc
	_ = extra.method_modifier_str(reflection.Method_Info{})         // same, from a Method_Info
	_ = extra.type_visibility(reflection.Type_Attributes_Public)    // "public" etc
	// renders a single param like c# would print it, e.g. "out int foo"
	_ = extra.parameter_format_csharp(reflection.Parameter_Info{}, reflection.type_il_name(0))
	// write_word is the low-level builder helper these formatters use
	// internally it just appends a word with spacing handled for u
	b := strings.Builder{}
	extra.write_word(&b, "hello") // append "hello " (token + space)
	strings.builder_destroy(&b)   // free the builder buffer
}

// scan is the pe/module-walking layer used to find signatures and resolve
// relative addresses. same stuff cov_resolver uses up top, just poked at
// directly here against kernel32.dll so it still runs even without a game
// process mapped in
cov_pure_scan :: proc () {
	sc, ok := scan.module_info_from_name("kernel32.dll") // grab a mapped module
	if !ok {
		return
	}
	// pattern/resolve helpers are pure on a mapped module.
	_, _ = scan.find_pattern_in_module(sc, CLASS_FROM_NAME_SIG) // scan the module for our sig
	// grab the .text section's rva + virtual size, so u know where to scan
	rva, vsz, sok := scan.module_section(sc, [4]byte{'.', 't', 'e', 'x'}) // .text section
	_, _, _ = rva, vsz, sok
	_ = scan.module_import_dir(sc) // import directory rva
	// address resolvers: turn a `call rel32`/`lea rip+X`/`mov rax,[rip+X]`
	// instruction at sc.base into the absolute address it points to
	_ = scan.resolve_call_rel32(sc.base) // E8 call -> target address
	_ = scan.resolve_rip_rel(sc.base)    // [rip+disp] -> target address
	_ = scan.resolve_lea_rip(sc.base)    // lea rip-rel -> target address

	// fake a `jz rel32` (0x0F 0x84) opcode so the finders below have
	// something real to match against
	buf2: [32]byte
	buf2[0], buf2[1] = 0x0F, 0x84 // fake `jz rel32` opcode
	_, _ = scan.find_mov_imm32(raw_data(buf2[:]), uint(len(buf2)), 0, 0) // find mov imm32
	_, _ = scan.find_gate_jz(raw_data(buf2[:]), uint(len(buf2)), 0)      // find a gate jz
	// low-level byte patchers. nop out a jump, or overwrite a single byte
	// (0x90 = the NOP opcode). also pure, no live process needed.
	_ = hook.nop_rel32(raw_data(buf2[:]), 0)  // nop out a rel32
	_ = hook.patch_byte(raw_data(buf2[:]), 0, 0x90) // write 0x90 (NOP)
}

// has_flags is just a bitmask check ((a & b) == b basically), but its typed
// per attribute-kind so we gotta exercise it against each enum separately
cov_reflection_atoms :: proc () {
	// pure attribute bit math! no runtime needed.
	_ = reflection.has_flags(reflection.Field_Attributes_Public, reflection.Field_Attributes_Static) // field flags
	_ = reflection.has_flags(
		reflection.Method_Attributes_Public | reflection.Method_Attributes_Static,
		reflection.Method_Attributes_Public,
	) // method flags (combined)
	_ = reflection.has_flags(reflection.Type_Attributes_Interface, reflection.Type_Attributes_ClassSemanticsMask) // type flags
	_ = reflection.has_flags(reflection.Property_Attributes_SpecialName, reflection.Property_Attributes_None) // property flags
	_ = reflection.Binding_Flags_OptionalParamBinding // a binding-flag constant
}

// just proves log.infof can format extra/reflection return values directly
// (bools, strings) without us having to unwrap or convert anything first
cov_format :: proc () {
	log.infof(
		"[coverage] attr bits ok: %v / %v",
		reflection.has_flags(reflection.Field_Attributes_Public, reflection.Field_Attributes_Static),
		extra.class_full_name(0),
	) // log results straight from the helpers
}

// --- frame (reflection-based field mapping) ---------------------------------

// a fake struct standing in for a "real" il2cpp instance layout.
// frame_of maps this onto a live object by matching field names, so u get to
// read/write fields thru normal odin struct syntax instead of raw offsets
Frame_Fake :: struct {
	value:  i32,
	active: bool,
}

// walks the whole frame lifecycle: build it, read it, write it, then poke
// at the lower-level matching helpers frame_read/frame_write use internally
cov_frame :: proc () {
	// maps Frame_Fake's fields onto object handle 0 by name. this is what
	// u call once per type, then reuse the frame for every instance
	//
	// extra.frame_of :: proc(class: il2cpp.Il2CppClass, $T: typeid, allocator := context.allocator) -> (_: Frame, _: bool)
	frame, ok := extra.frame_of(0, Frame_Fake) // build the frame
	if !ok {
		return
	}
	defer extra.frame_destroy(&frame) // free the frame at the end
	tag := reflect.Struct_Tag("")     // empty tag for matching
	extra.frame_read(frame, 0, Frame_Fake)                    // copy managed fields into our struct
	extra.frame_write(frame, 0, Frame_Fake{value = 1, active = true}) // push our struct back out

	// the lower-level plumbing frame_read/frame_write use internally:
	// figuring out how many bytes a field spans, matching a struct tag
	// (e.g. `il2cpp:"fieldName"`) to a candidate field name, etc
	extra.frame_field_extent({0, 1, 2}, 0, 3) // bytes a field spans
	_ = extra.frame_tag_name(tag)             // read the `frame:"..."` tag
	cands := extra.frame_field_candidates("value", tag) // possible field names to try
	_ = cands
	_ = extra.frame_candidates_contain(cands, 0, "value") // is "value" in the candidates?
	_, _, _ = extra.frame_resolve_field(0, "value", tag)  // pick the best-matching field
}
