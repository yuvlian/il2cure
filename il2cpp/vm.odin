package il2cpp

// resolve fetches a typed proc from the api cache.
// returns a nil proc (and the caller's call is a no-op) if the export is missing.
resolve :: proc ($T: typeid, name: string) -> T {
	p := api(name)
	if p == nil {
		return {}
	}
	return cast(T)p
}

// --- lifecycle ----------------------------------------------------------

vm_il2cpp_init :: proc (domain_name: cstring) {
	resolve(proc "c" (cstring), "il2cpp_init")(domain_name)
}

vm_il2cpp_init_utf16 :: proc (domain_name: cstring16) -> Il2CppDomain {
	return resolve(proc "c" (cstring16) -> Il2CppDomain, "il2cpp_init_utf16")(domain_name)
}

vm_il2cpp_shutdown :: proc () {
	resolve(proc "c" (), "il2cpp_shutdown")()
}

vm_il2cpp_set_config_dir :: proc (dir: cstring) {
	resolve(proc "c" (cstring), "il2cpp_set_config_dir")(dir)
}

vm_il2cpp_set_data_dir :: proc (dir: cstring) {
	resolve(proc "c" (cstring), "il2cpp_set_data_dir")(dir)
}

vm_il2cpp_set_temp_dir :: proc (dir: cstring) {
	resolve(proc "c" (cstring), "il2cpp_set_temp_dir")(dir)
}

vm_il2cpp_set_commandline_arguments :: proc (argc: i32, argv: ^^cstring, basedir: cstring) {
	resolve(
		proc "c" (i32, ^^cstring, cstring),
		"il2cpp_set_commandline_arguments",
	)(argc, argv, basedir)
}

vm_il2cpp_set_commandline_arguments_utf16 :: proc (
	argc:    i32,
	argv:    ^^cstring,
	basedir: cstring,
) {
	resolve(proc "c" (i32, ^^cstring, cstring),
		"il2cpp_set_commandline_arguments_utf16")(argc, argv, basedir)
}

vm_il2cpp_set_config :: proc (key: cstring, value: cstring) {
	resolve(proc "c" (cstring, cstring), "il2cpp_set_config")(key, value)
}

vm_il2cpp_set_config_utf16 :: proc (key: cstring16, value: cstring16) {
	resolve(proc "c" (cstring16, cstring16), "il2cpp_set_config_utf16")(key, value)
}

vm_il2cpp_set_memory_callbacks :: proc (cbs: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_set_memory_callbacks")(cbs)
}

vm_il2cpp_memory_pool_set_region_size :: proc (size: uintptr) {
	resolve(proc "c" (uintptr), "il2cpp_memory_pool_set_region_size")(size)
}

vm_il2cpp_memory_pool_get_region_size :: proc () -> uintptr {
	return resolve(proc "c" () -> uintptr, "il2cpp_memory_pool_get_region_size")()
}

vm_il2cpp_get_corlib :: proc () -> Il2CppImage {
	return resolve(proc "c" () -> Il2CppImage, "il2cpp_get_corlib")()
}

vm_il2cpp_add_internal_call :: proc (name: cstring, method: rawptr) {
	resolve(proc "c" (cstring, rawptr), "il2cpp_add_internal_call")(name, method)
}

vm_il2cpp_resolve_icall :: proc (name: cstring) -> rawptr {
	return resolve(proc "c" (cstring) -> rawptr, "il2cpp_resolve_icall")(name)
}

vm_il2cpp_alloc :: proc (size: uintptr) -> rawptr {
	return resolve(proc "c" (uintptr) -> rawptr, "il2cpp_alloc")(size)
}

vm_il2cpp_free :: proc (p: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_free")(p)
}

// --- arrays --------------------------------------------------------------

vm_il2cpp_array_class_get :: proc (element_class: Il2CppClass, rank: u32) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppClass, u32) -> Il2CppClass,
		"il2cpp_array_class_get",
	)(element_class, rank)
}

vm_il2cpp_array_length :: proc (array: Il2CppArray) -> uintptr {
	return resolve(proc "c" (Il2CppArray) -> uintptr, "il2cpp_array_length")(array)
}

vm_il2cpp_array_get_byte_length :: proc (array: Il2CppArray) -> u32 {
	return resolve(proc "c" (Il2CppArray) -> u32, "il2cpp_array_get_byte_length")(array)
}

vm_il2cpp_array_new :: proc (element_class: Il2CppClass, length: uintptr) -> Il2CppArray {
	return resolve(
		proc "c" (Il2CppClass, uintptr) -> Il2CppArray,
		"il2cpp_array_new",
	)(element_class, length)
}

vm_il2cpp_array_new_specific :: proc (
	array_class: Il2CppClass,
	length:      uintptr,
) -> Il2CppArray {
	return resolve(
		proc "c" (Il2CppClass, uintptr) -> Il2CppArray,
		"il2cpp_array_new_specific",
	)(array_class, length)
}

vm_il2cpp_array_new_full :: proc (
	array_class:  Il2CppClass,
	lengths:      ^uintptr,
	lower_bounds: ^uintptr,
) -> Il2CppArray {
	return resolve(
		proc "c" (Il2CppClass, ^uintptr, ^uintptr) -> Il2CppArray,
		"il2cpp_array_new_full",
	)(array_class, lengths, lower_bounds)
}

vm_il2cpp_bounded_array_class_get :: proc (
	element_class: Il2CppClass,
	rank:          u32,
	bounded:       bool,
) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppClass, u32, bool) -> Il2CppClass,
		"il2cpp_bounded_array_class_get",
	)(element_class, rank, bounded)
}

vm_il2cpp_array_element_size :: proc (array_class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, "il2cpp_array_element_size")(array_class)
}

// --- asm / image ----------------------------------------------------------

vm_il2cpp_assembly_get_image :: proc (assembly: Il2CppAssembly) -> Il2CppImage {
	return resolve(
		proc "c" (Il2CppAssembly) -> Il2CppImage,
		"il2cpp_assembly_get_image",
	)(assembly)
}

vm_il2cpp_image_get_assembly :: proc (image: Il2CppImage) -> Il2CppAssembly {
	return resolve(
		proc "c" (Il2CppImage) -> Il2CppAssembly,
		"il2cpp_image_get_assembly",
	)(image)
}

vm_il2cpp_image_get_name :: proc (image: Il2CppImage) -> cstring {
	return resolve(proc "c" (Il2CppImage) -> cstring, "il2cpp_image_get_name")(image)
}

vm_il2cpp_image_get_filename :: proc (image: Il2CppImage) -> cstring {
	return resolve(proc "c" (Il2CppImage) -> cstring, "il2cpp_image_get_filename")(image)
}

vm_il2cpp_image_get_entry_point :: proc (image: Il2CppImage) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppImage) -> Il2CppMethod,
		"il2cpp_image_get_entry_point",
	)(image)
}

vm_il2cpp_image_get_class_count :: proc (image: Il2CppImage) -> uintptr {
	return resolve(proc "c" (Il2CppImage) -> uintptr, "il2cpp_image_get_class_count")(image)
}

vm_il2cpp_image_get_class :: proc (image: Il2CppImage, index: uintptr) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppImage, uintptr) -> Il2CppClass,
		"il2cpp_image_get_class",
	)(image, index)
}

// --- class ---------------------------------------------------------------

vm_il2cpp_class_for_each :: proc (visit: rawptr, user_data: rawptr) {
	resolve(proc "c" (rawptr, rawptr), "il2cpp_class_for_each")(visit, user_data)
}

vm_il2cpp_class_enum_basetype :: proc (class: Il2CppClass) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppClass) -> Il2CppType,
		"il2cpp_class_enum_basetype",
	)(class)
}

vm_il2cpp_class_is_inited :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, "il2cpp_class_is_inited")(class)
}

vm_il2cpp_class_is_generic :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, "il2cpp_class_is_generic")(class)
}

vm_il2cpp_class_is_inflated :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, "il2cpp_class_is_inflated")(class)
}

vm_il2cpp_class_is_assignable_from :: proc (
	class: Il2CppClass,
	other: Il2CppClass,
) -> bool {
	return resolve(
		proc "c" (Il2CppClass, Il2CppClass) -> bool,
		"il2cpp_class_is_assignable_from",
	)(class, other)
}

vm_il2cpp_class_is_subclass_of :: proc (
	class:            Il2CppClass,
	base:             Il2CppClass,
	check_interfaces: bool,
) -> bool {
	return resolve(
		proc "c" (Il2CppClass, Il2CppClass, bool) -> bool,
		"il2cpp_class_is_subclass_of",
	)(class, base, check_interfaces)
}

vm_il2cpp_class_has_parent :: proc (class: Il2CppClass, parent: Il2CppClass) -> bool {
	return resolve(
		proc "c" (Il2CppClass, Il2CppClass) -> bool,
		"il2cpp_class_has_parent",
	)(class, parent)
}

vm_il2cpp_class_from_il2cpp_type :: proc (t: Il2CppType) -> Il2CppClass {
	return resolve(proc "c" (Il2CppType) -> Il2CppClass, "il2cpp_class_from_il2cpp_type")(t)
}

vm_il2cpp_class_from_name :: proc (
	image:      Il2CppImage,
	namespace: cstring,
	name:       cstring,
) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppImage, cstring, cstring) -> Il2CppClass,
		"il2cpp_class_from_name",
	)(image, namespace, name)
}

vm_il2cpp_class_from_system_type :: proc (t: Il2CppObject) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppObject) -> Il2CppClass,
		"il2cpp_class_from_system_type",
	)(t)
}

vm_il2cpp_class_get_element_class :: proc (class: Il2CppClass) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppClass) -> Il2CppClass,
		"il2cpp_class_get_element_class",
	)(class)
}

vm_il2cpp_class_get_events :: proc (class: Il2CppClass, iter: ^rawptr) -> Il2CppEventInfo {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppEventInfo,
		"il2cpp_class_get_events",
	)(class, iter)
}

vm_il2cpp_class_get_fields :: proc (class: Il2CppClass, iter: ^rawptr) -> Il2CppField {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppField,
		"il2cpp_class_get_fields",
	)(class, iter)
}

vm_il2cpp_class_get_nested_types :: proc (
	class: Il2CppClass,
	iter:  ^rawptr,
) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppClass,
		"il2cpp_class_get_nested_types",
	)(class, iter)
}

vm_il2cpp_class_get_interfaces :: proc (class: Il2CppClass, iter: ^rawptr) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppType,
		"il2cpp_class_get_interfaces",
	)(class, iter)
}

vm_il2cpp_class_get_properties :: proc (
	class: Il2CppClass,
	iter:  ^rawptr,
) -> Il2CppProperty {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppProperty,
		"il2cpp_class_get_properties",
	)(class, iter)
}

vm_il2cpp_class_get_property_from_name :: proc (
	class: Il2CppClass,
	name:  cstring,
) -> Il2CppProperty {
	return resolve(
		proc "c" (Il2CppClass, cstring) -> Il2CppProperty,
		"il2cpp_class_get_property_from_name",
	)(class, name)
}

vm_il2cpp_class_get_field_from_name :: proc (
	class: Il2CppClass,
	name:  cstring,
) -> Il2CppField {
	return resolve(
		proc "c" (Il2CppClass, cstring) -> Il2CppField,
		"il2cpp_class_get_field_from_name",
	)(class, name)
}

vm_il2cpp_class_get_methods :: proc (class: Il2CppClass, iter: ^rawptr) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppMethod,
		"il2cpp_class_get_methods",
	)(class, iter)
}

vm_il2cpp_class_get_method_from_name :: proc (
	class:     Il2CppClass,
	name:      cstring,
	arg_count: i32,
) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppClass, cstring, i32) -> Il2CppMethod,
		"il2cpp_class_get_method_from_name",
	)(class, name, arg_count)
}

vm_il2cpp_class_get_name :: proc (class: Il2CppClass) -> cstring {
	return resolve(proc "c" (Il2CppClass) -> cstring, "il2cpp_class_get_name")(class)
}

vm_il2cpp_class_get_namespace :: proc (class: Il2CppClass) -> cstring {
	return resolve(proc "c" (Il2CppClass) -> cstring, "il2cpp_class_get_namespace")(class)
}

vm_il2cpp_class_get_parent :: proc (class: Il2CppClass) -> Il2CppClass {
	return resolve(proc "c" (Il2CppClass) -> Il2CppClass, "il2cpp_class_get_parent")(class)
}

vm_il2cpp_class_get_declaring_type :: proc (class: Il2CppClass) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppClass) -> Il2CppType,
		"il2cpp_class_get_declaring_type",
	)(class)
}

vm_il2cpp_class_instance_size :: proc (class: Il2CppClass) -> i32 {
	return resolve(proc "c" (Il2CppClass) -> i32, "il2cpp_class_instance_size")(class)
}

vm_il2cpp_class_num_fields :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, "il2cpp_class_num_fields")(class)
}

vm_il2cpp_class_is_valuetype :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, "il2cpp_class_is_valuetype")(class)
}

vm_il2cpp_class_value_size :: proc (class: Il2CppClass, align: ^u32) -> u32 {
	return resolve(
		proc "c" (Il2CppClass, ^u32) -> u32,
		"il2cpp_class_value_size",
	)(class, align)
}

vm_il2cpp_class_is_blittable :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, "il2cpp_class_is_blittable")(class)
}

vm_il2cpp_class_get_flags :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, "il2cpp_class_get_flags")(class)
}

vm_il2cpp_class_is_abstract :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, "il2cpp_class_is_abstract")(class)
}

vm_il2cpp_class_is_interface :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, "il2cpp_class_is_interface")(class)
}

vm_il2cpp_class_array_element_size :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, "il2cpp_class_array_element_size")(class)
}

vm_il2cpp_class_from_type :: proc (t: Il2CppType) -> Il2CppClass {
	return resolve(proc "c" (Il2CppType) -> Il2CppClass, "il2cpp_class_from_type")(t)
}

vm_il2cpp_class_get_type :: proc (class: Il2CppClass) -> Il2CppType {
	return resolve(proc "c" (Il2CppClass) -> Il2CppType, "il2cpp_class_get_type")(class)
}

vm_il2cpp_class_get_type_token :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, "il2cpp_class_get_type_token")(class)
}

vm_il2cpp_class_has_attribute :: proc (class: Il2CppClass, attr: Il2CppClass) -> bool {
	return resolve(
		proc "c" (Il2CppClass, Il2CppClass) -> bool,
		"il2cpp_class_has_attribute",
	)(class, attr)
}

vm_il2cpp_class_has_references :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, "il2cpp_class_has_references")(class)
}

vm_il2cpp_class_is_enum :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, "il2cpp_class_is_enum")(class)
}

vm_il2cpp_class_get_image :: proc (class: Il2CppClass) -> Il2CppImage {
	return resolve(proc "c" (Il2CppClass) -> Il2CppImage, "il2cpp_class_get_image")(class)
}

vm_il2cpp_class_get_assemblyname :: proc (class: Il2CppClass) -> cstring {
	return resolve(
		proc "c" (Il2CppClass) -> cstring,
		"il2cpp_class_get_assemblyname",
	)(class)
}

vm_il2cpp_class_get_rank :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, "il2cpp_class_get_rank")(class)
}

vm_il2cpp_class_get_data_size :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, "il2cpp_class_get_data_size")(class)
}

vm_il2cpp_class_get_static_field_data :: proc (class: Il2CppClass) -> rawptr {
	return resolve(
		proc "c" (Il2CppClass) -> rawptr,
		"il2cpp_class_get_static_field_data",
	)(class)
}

// --- stats ----------------------------------------------------------------

vm_il2cpp_stats_dump_to_file :: proc (path: cstring) -> i32 {
	return resolve(proc "c" (cstring) -> i32, "il2cpp_stats_dump_to_file")(path)
}

vm_il2cpp_stats_get_value :: proc (counter: u32) -> i64 {
	return resolve(proc "c" (u32) -> i64, "il2cpp_stats_get_value")(counter)
}

// --- domain ---------------------------------------------------------------

vm_il2cpp_domain_get :: proc () -> Il2CppDomain {
	return resolve(proc "c" () -> Il2CppDomain, "il2cpp_domain_get")()
}

vm_il2cpp_domain_assembly_open :: proc (
	domain: Il2CppDomain,
	name:   cstring,
) -> Il2CppAssembly {
	return resolve(
		proc "c" (Il2CppDomain, cstring) -> Il2CppAssembly,
		"il2cpp_domain_assembly_open",
	)(domain, name)
}

vm_il2cpp_domain_get_assemblies :: proc (
	domain: Il2CppDomain,
	count:  ^uintptr,
) -> [^]Il2CppAssembly {
	return resolve(
		proc "c" (Il2CppDomain, ^uintptr) -> [^]Il2CppAssembly,
		"il2cpp_domain_get_assemblies",
	)(domain, count)
}

// --- exceptions ------------------------------------------------------------

vm_il2cpp_raise_exception :: proc (ex: Il2CppException) -> ! {
	resolve(proc "c" (Il2CppException), "il2cpp_raise_exception")(ex)
	unreachable()
}

vm_il2cpp_exception_from_name_msg :: proc (
	image:      Il2CppImage,
	namespace: cstring,
	name:       cstring,
	msg:        cstring,
) -> Il2CppException {
	return resolve(
		proc "c" (Il2CppImage, cstring, cstring, cstring) -> Il2CppException,
		"il2cpp_exception_from_name_msg",
	)(image, namespace, name, msg)
}

vm_il2cpp_get_exception_argument_null :: proc (arg: cstring) -> Il2CppException {
	return resolve(
		proc "c" (cstring) -> Il2CppException,
		"il2cpp_get_exception_argument_null",
	)(arg)
}

vm_il2cpp_format_exception :: proc (ex: Il2CppException) -> cstring {
	return resolve(proc "c" (Il2CppException) -> cstring, "il2cpp_format_exception")(ex)
}

vm_il2cpp_format_stack_trace :: proc (ex: Il2CppException) -> cstring {
	return resolve(proc "c" (Il2CppException) -> cstring, "il2cpp_format_stack_trace")(ex)
}

vm_il2cpp_unhandled_exception :: proc (ex: Il2CppException) -> ! {
	resolve(proc "c" (Il2CppException), "il2cpp_unhandled_exception")(ex)
	unreachable()
}

vm_il2cpp_native_stack_trace :: proc (frames: ^Il2CppStackFrameInfo, frame_count: u32) {
	resolve(
		proc "c" (^Il2CppStackFrameInfo, u32),
		"il2cpp_native_stack_trace",
	)(frames, frame_count)
}

// --- fields ----------------------------------------------------------------

vm_il2cpp_field_get_flags :: proc (field: Il2CppField) -> u32 {
	return resolve(proc "c" (Il2CppField) -> u32, "il2cpp_field_get_flags")(field)
}

vm_il2cpp_field_get_from_reflection :: proc (obj: Il2CppObject) -> Il2CppField {
	return resolve(
		proc "c" (Il2CppObject) -> Il2CppField,
		"il2cpp_field_get_from_reflection",
	)(obj)
}

vm_il2cpp_field_get_name :: proc (field: Il2CppField) -> cstring {
	return resolve(proc "c" (Il2CppField) -> cstring, "il2cpp_field_get_name")(field)
}

vm_il2cpp_field_get_parent :: proc (field: Il2CppField) -> Il2CppClass {
	return resolve(proc "c" (Il2CppField) -> Il2CppClass, "il2cpp_field_get_parent")(field)
}

vm_il2cpp_field_get_object :: proc (
	obj:   Il2CppObject,
	field: Il2CppField,
	value: ^rawptr,
) -> Il2CppObject {
	return resolve(
		proc "c" (Il2CppObject, Il2CppField, ^rawptr) -> Il2CppObject,
		"il2cpp_field_get_object",
	)(obj, field, value)
}

vm_il2cpp_field_get_offset :: proc (field: Il2CppField) -> uintptr {
	return resolve(proc "c" (Il2CppField) -> uintptr, "il2cpp_field_get_offset")(field)
}

vm_il2cpp_field_get_type :: proc (field: Il2CppField) -> Il2CppType {
	return resolve(proc "c" (Il2CppField) -> Il2CppType, "il2cpp_field_get_type")(field)
}

vm_il2cpp_field_get_value :: proc (obj: Il2CppObject, field: Il2CppField, value: rawptr) {
	resolve(
		proc "c" (Il2CppObject, Il2CppField, rawptr),
		"il2cpp_field_get_value",
	)(obj, field, value)
}

vm_il2cpp_field_get_value_object :: proc (
	field: Il2CppField,
	obj:   Il2CppObject,
	class: Il2CppClass,
) -> Il2CppObject {
	return resolve(
		proc "c" (Il2CppField, Il2CppObject, Il2CppClass) -> Il2CppObject,
		"il2cpp_field_get_value_object",
	)(field, obj, class)
}

vm_il2cpp_field_has_attribute :: proc (field: Il2CppField, attr: Il2CppClass) -> bool {
	return resolve(
		proc "c" (Il2CppField, Il2CppClass) -> bool,
		"il2cpp_field_has_attribute",
	)(field, attr)
}

vm_il2cpp_field_set_value :: proc (obj: Il2CppObject, field: Il2CppField, value: rawptr) {
	resolve(
		proc "c" (Il2CppObject, Il2CppField, rawptr),
		"il2cpp_field_set_value",
	)(obj, field, value)
}

vm_il2cpp_field_static_get_value :: proc (field: Il2CppField, value: rawptr) {
	resolve(proc "c" (Il2CppField, rawptr), "il2cpp_field_static_get_value")(field, value)
}

vm_il2cpp_field_static_set_value :: proc (field: Il2CppField, value: rawptr) {
	resolve(proc "c" (Il2CppField, rawptr), "il2cpp_field_static_set_value")(field, value)
}

vm_il2cpp_field_set_value_object :: proc (
	class: Il2CppClass,
	obj:   Il2CppObject,
	field: Il2CppField,
	value: Il2CppObject,
) {
	resolve(
		proc "c" (Il2CppClass, Il2CppObject, Il2CppField, Il2CppObject),
		"il2cpp_field_set_value_object",
	)(class, obj, field, value)
}

vm_il2cpp_field_is_literal :: proc (field: Il2CppField) -> bool {
	return resolve(proc "c" (Il2CppField) -> bool, "il2cpp_field_is_literal")(field)
}

// --- gc --------------------------------------------------------------------

vm_il2cpp_gc_collect :: proc (force: i32) {
	resolve(proc "c" (i32), "il2cpp_gc_collect")(force)
}

vm_il2cpp_gc_collect_a_little :: proc () {
	resolve(proc "c" (), "il2cpp_gc_collect_a_little")()
}

vm_il2cpp_gc_start_incremental_collection :: proc () {
	resolve(proc "c" (), "il2cpp_gc_start_incremental_collection")()
}

vm_il2cpp_gc_disable :: proc () {
	resolve(proc "c" (), "il2cpp_gc_disable")()
}

vm_il2cpp_gc_enable :: proc () {
	resolve(proc "c" (), "il2cpp_gc_enable")()
}

vm_il2cpp_gc_is_disabled :: proc () -> bool {
	return resolve(proc "c" () -> bool, "il2cpp_gc_is_disabled")()
}

vm_il2cpp_gc_set_mode :: proc (mode: i32) {
	resolve(proc "c" (i32), "il2cpp_gc_set_mode")(mode)
}

vm_il2cpp_gc_get_max_time_slice_ns :: proc () -> i64 {
	return resolve(proc "c" () -> i64, "il2cpp_gc_get_max_time_slice_ns")()
}

vm_il2cpp_gc_set_max_time_slice_ns :: proc (ns: i64) {
	resolve(proc "c" (i64), "il2cpp_gc_set_max_time_slice_ns")(ns)
}

vm_il2cpp_gc_is_incremental :: proc () -> bool {
	return resolve(proc "c" () -> bool, "il2cpp_gc_is_incremental")()
}

vm_il2cpp_gc_get_used_size :: proc () -> i64 {
	return resolve(proc "c" () -> i64, "il2cpp_gc_get_used_size")()
}

vm_il2cpp_gc_get_heap_size :: proc () -> i64 {
	return resolve(proc "c" () -> i64, "il2cpp_gc_get_heap_size")()
}

vm_il2cpp_gc_wbarrier_set_field :: proc (
	obj:    Il2CppObject,
	target: ^rawptr,
	value:  Il2CppObject,
) {
	resolve(
		proc "c" (Il2CppObject, ^rawptr, Il2CppObject),
		"il2cpp_gc_wbarrier_set_field",
	)(obj, target, value)
}

vm_il2cpp_gc_has_strict_wbarriers :: proc () -> bool {
	return resolve(proc "c" () -> bool, "il2cpp_gc_has_strict_wbarriers")()
}

vm_il2cpp_gc_set_external_allocation_tracker :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_gc_set_external_allocation_tracker")(cb)
}

vm_il2cpp_gc_set_external_wbarrier_tracker :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_gc_set_external_wbarrier_tracker")(cb)
}

vm_il2cpp_gc_foreach_heap :: proc (cb: rawptr, user_data: rawptr) {
	resolve(proc "c" (rawptr, rawptr), "il2cpp_gc_foreach_heap")(cb, user_data)
}

vm_il2cpp_stop_gc_world :: proc (force: i32) {
	resolve(proc "c" (i32), "il2cpp_stop_gc_world")(force)
}

vm_il2cpp_start_gc_world :: proc () {
	resolve(proc "c" (), "il2cpp_start_gc_world")()
}

vm_il2cpp_gc_alloc_fixed :: proc (size: uintptr, offset: uintptr) -> rawptr {
	return resolve(
		proc "c" (uintptr, uintptr) -> rawptr,
		"il2cpp_gc_alloc_fixed",
	)(size, offset)
}

vm_il2cpp_gc_free_fixed :: proc (p: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_gc_free_fixed")(p)
}

// --- gchandle ----------------------------------------------------------------

vm_il2cpp_gchandle_new :: proc (obj: Il2CppObject, pinned: bool) -> GCHandle {
	return resolve(
		proc "c" (Il2CppObject, bool) -> GCHandle,
		"il2cpp_gchandle_new",
	)(obj, pinned)
}

vm_il2cpp_gchandle_new_weakref :: proc (
	obj:                Il2CppObject,
	track_resurrection: bool,
) -> GCHandle {
	return resolve(
		proc "c" (Il2CppObject, bool) -> GCHandle,
		"il2cpp_gchandle_new_weakref",
	)(obj, track_resurrection)
}

vm_il2cpp_gchandle_get_target :: proc (handle: GCHandle) -> Il2CppObject {
	return resolve(
		proc "c" (GCHandle) -> Il2CppObject,
		"il2cpp_gchandle_get_target",
	)(handle)
}

vm_il2cpp_gchandle_free :: proc (handle: GCHandle) {
	resolve(proc "c" (GCHandle), "il2cpp_gchandle_free")(handle)
}

vm_il2cpp_gchandle_foreach_get_target :: proc (
	handle:    GCHandle,
	user_data: rawptr,
	cb:        rawptr,
) {
	resolve(
		proc "c" (GCHandle, rawptr, rawptr),
		"il2cpp_gchandle_foreach_get_target",
	)(handle, user_data, cb)
}

// --- object layout -----------------------------------------------------------

vm_il2cpp_object_header_size :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, "il2cpp_object_header_size")(class)
}

vm_il2cpp_array_object_header_size :: proc () -> uintptr {
	return resolve(proc "c" () -> uintptr, "il2cpp_array_object_header_size")()
}

vm_il2cpp_offset_of_array_length_in_array_object_header :: proc () -> uintptr {
	return resolve(
		proc "c" () -> uintptr,
		"il2cpp_offset_of_array_length_in_array_object_header",
	)()
}

vm_il2cpp_offset_of_array_bounds_in_array_object_header :: proc () -> uintptr {
	return resolve(
		proc "c" () -> uintptr,
		"il2cpp_offset_of_array_bounds_in_array_object_header",
	)()
}

vm_il2cpp_allocation_granularity :: proc () -> uintptr {
	return resolve(proc "c" () -> uintptr, "il2cpp_allocation_granularity")()
}

// --- unity liveness --------------------------------------------------------

vm_il2cpp_unity_liveness_allocate_struct :: proc (
	state: rawptr,
	size:  i32,
	arena: rawptr,
) -> rawptr {
	return resolve(
		proc "c" (rawptr, i32, rawptr) -> rawptr,
		"il2cpp_unity_liveness_allocate_struct",
	)(state, size, arena)
}

vm_il2cpp_unity_liveness_calculation_from_root :: proc (
	state:      rawptr,
	roots:      ^Il2CppObject,
	root_count: i32,
) {
	resolve(
		proc "c" (rawptr, ^Il2CppObject, i32),
		"il2cpp_unity_liveness_calculation_from_root",
	)(state, roots, root_count)
}

vm_il2cpp_unity_liveness_calculation_from_statics :: proc (state: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_unity_liveness_calculation_from_statics")(state)
}

vm_il2cpp_unity_liveness_finalize :: proc (state: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_unity_liveness_finalize")(state)
}

vm_il2cpp_unity_liveness_free_struct :: proc (state: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_unity_liveness_free_struct")(state)
}

// --- method ----------------------------------------------------------------

vm_il2cpp_method_get_return_type :: proc (method: Il2CppMethod) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppMethod) -> Il2CppType,
		"il2cpp_method_get_return_type",
	)(method)
}

vm_il2cpp_method_get_declaring_type :: proc (method: Il2CppMethod) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppMethod) -> Il2CppType,
		"il2cpp_method_get_declaring_type",
	)(method)
}

vm_il2cpp_method_get_name :: proc (method: Il2CppMethod) -> cstring {
	return resolve(proc "c" (Il2CppMethod) -> cstring, "il2cpp_method_get_name")(method)
}

vm_il2cpp_method_get_from_reflection :: proc (obj: Il2CppObject) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppObject) -> Il2CppMethod,
		"il2cpp_method_get_from_reflection",
	)(obj)
}

vm_il2cpp_method_get_object :: proc (
	class:    Il2CppClass,
	method:   Il2CppMethod,
	refclass: Il2CppClass,
) -> Il2CppObject {
	return resolve(
		proc "c" (Il2CppClass, Il2CppMethod, Il2CppClass) -> Il2CppObject,
		"il2cpp_method_get_object",
	)(class, method, refclass)
}

vm_il2cpp_method_is_generic :: proc (method: Il2CppMethod) -> bool {
	return resolve(proc "c" (Il2CppMethod) -> bool, "il2cpp_method_is_generic")(method)
}

vm_il2cpp_method_is_inflated :: proc (method: Il2CppMethod) -> bool {
	return resolve(proc "c" (Il2CppMethod) -> bool, "il2cpp_method_is_inflated")(method)
}

vm_il2cpp_method_is_instance :: proc (method: Il2CppMethod) -> bool {
	return resolve(proc "c" (Il2CppMethod) -> bool, "il2cpp_method_is_instance")(method)
}

vm_il2cpp_method_get_param_count :: proc (method: Il2CppMethod) -> u32 {
	return resolve(proc "c" (Il2CppMethod) -> u32, "il2cpp_method_get_param_count")(method)
}

vm_il2cpp_method_get_param :: proc (method: Il2CppMethod, index: u32) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppMethod, u32) -> Il2CppType,
		"il2cpp_method_get_param",
	)(method, index)
}

vm_il2cpp_method_get_class :: proc (method: Il2CppMethod) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppMethod) -> Il2CppClass,
		"il2cpp_method_get_class",
	)(method)
}

vm_il2cpp_method_has_attribute :: proc (method: Il2CppMethod, attr: Il2CppClass) -> bool {
	return resolve(
		proc "c" (Il2CppMethod, Il2CppClass) -> bool,
		"il2cpp_method_has_attribute",
	)(method, attr)
}

vm_il2cpp_method_get_flags :: proc (method: Il2CppMethod, iflags: ^u32) -> u32 {
	return resolve(
		proc "c" (Il2CppMethod, ^u32) -> u32,
		"il2cpp_method_get_flags",
	)(method, iflags)
}

vm_il2cpp_method_get_token :: proc (method: Il2CppMethod) -> u32 {
	return resolve(proc "c" (Il2CppMethod) -> u32, "il2cpp_method_get_token")(method)
}

vm_il2cpp_method_get_param_name :: proc (method: Il2CppMethod, index: u32) -> cstring {
	return resolve(
		proc "c" (Il2CppMethod, u32) -> cstring,
		"il2cpp_method_get_param_name",
	)(method, index)
}

// --- property ----------------------------------------------------------------

vm_il2cpp_property_get_flags :: proc (prop: Il2CppProperty) -> u32 {
	return resolve(proc "c" (Il2CppProperty) -> u32, "il2cpp_property_get_flags")(prop)
}

vm_il2cpp_property_get_get_method :: proc (prop: Il2CppProperty) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppProperty) -> Il2CppMethod,
		"il2cpp_property_get_get_method",
	)(prop)
}

vm_il2cpp_property_get_set_method :: proc (prop: Il2CppProperty) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppProperty) -> Il2CppMethod,
		"il2cpp_property_get_set_method",
	)(prop)
}

vm_il2cpp_property_get_name :: proc (prop: Il2CppProperty) -> cstring {
	return resolve(proc "c" (Il2CppProperty) -> cstring, "il2cpp_property_get_name")(prop)
}

vm_il2cpp_property_get_parent :: proc (prop: Il2CppProperty) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppProperty) -> Il2CppClass,
		"il2cpp_property_get_parent",
	)(prop)
}

// --- object ----------------------------------------------------------------

vm_il2cpp_object_get_class :: proc (obj: Il2CppObject) -> Il2CppClass {
	return resolve(proc "c" (Il2CppObject) -> Il2CppClass, "il2cpp_object_get_class")(obj)
}

vm_il2cpp_object_get_size :: proc (obj: Il2CppObject) -> u32 {
	return resolve(proc "c" (Il2CppObject) -> u32, "il2cpp_object_get_size")(obj)
}

vm_il2cpp_object_get_virtual_method :: proc (
	obj:    Il2CppObject,
	method: Il2CppMethod,
	ref:    ^rawptr,
) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppObject, Il2CppMethod, ^rawptr) -> Il2CppMethod,
		"il2cpp_object_get_virtual_method",
	)(obj, method, ref)
}

vm_il2cpp_object_new :: proc (class: Il2CppClass) -> Il2CppObject {
	return resolve(proc "c" (Il2CppClass) -> Il2CppObject, "il2cpp_object_new")(class)
}

vm_il2cpp_object_unbox :: proc (obj: Il2CppObject) -> rawptr {
	return resolve(proc "c" (Il2CppObject) -> rawptr, "il2cpp_object_unbox")(obj)
}

vm_il2cpp_value_box :: proc (class: Il2CppClass, data: rawptr) -> Il2CppObject {
	return resolve(
		proc "c" (Il2CppClass, rawptr) -> Il2CppObject,
		"il2cpp_value_box",
	)(class, data)
}

// --- monitor ----------------------------------------------------------------

vm_il2cpp_monitor_enter :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), "il2cpp_monitor_enter")(obj)
}

vm_il2cpp_monitor_try_enter :: proc (obj: Il2CppObject, timeout_ms: u32) -> bool {
	return resolve(
		proc "c" (Il2CppObject, u32) -> bool,
		"il2cpp_monitor_try_enter",
	)(obj, timeout_ms)
}

vm_il2cpp_monitor_exit :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), "il2cpp_monitor_exit")(obj)
}

vm_il2cpp_monitor_pulse :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), "il2cpp_monitor_pulse")(obj)
}

vm_il2cpp_monitor_pulse_all :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), "il2cpp_monitor_pulse_all")(obj)
}

vm_il2cpp_monitor_wait :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), "il2cpp_monitor_wait")(obj)
}

vm_il2cpp_monitor_try_wait :: proc (obj: Il2CppObject, timeout_ms: u32) -> bool {
	return resolve(
		proc "c" (Il2CppObject, u32) -> bool,
		"il2cpp_monitor_try_wait",
	)(obj, timeout_ms)
}

// --- runtime invoke ----------------------------------------------------------

vm_il2cpp_runtime_invoke :: proc (
	method: Il2CppMethod,
	obj:    Il2CppObject,
	params: ^rawptr,
	exc:    ^Il2CppException,
) -> Il2CppObject {
	return resolve(
		proc "c" (Il2CppMethod, Il2CppObject, ^rawptr, ^Il2CppException) -> Il2CppObject,
		"il2cpp_runtime_invoke",
	)(method, obj, params, exc)
}

vm_il2cpp_runtime_invoke_convert_args :: proc (
	method:      Il2CppMethod,
	obj:         Il2CppObject,
	params:      ^Il2CppObject,
	param_count: i32,
	exc:         ^Il2CppException,
) -> Il2CppObject {
	return resolve(
		proc "c" (
			Il2CppMethod,
			Il2CppObject,
			^Il2CppObject,
			i32,
			^Il2CppException,
		) -> Il2CppObject,
		"il2cpp_runtime_invoke_convert_args",
	)(method, obj, params, param_count, exc)
}

vm_il2cpp_runtime_class_init :: proc (class: Il2CppClass) {
	resolve(proc "c" (Il2CppClass), "il2cpp_runtime_class_init")(class)
}

vm_il2cpp_runtime_object_init :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), "il2cpp_runtime_object_init")(obj)
}

vm_il2cpp_runtime_object_init_exception :: proc (obj: Il2CppObject, exc: ^Il2CppException) {
	resolve(
		proc "c" (Il2CppObject, ^Il2CppException),
		"il2cpp_runtime_object_init_exception",
	)(obj, exc)
}

vm_il2cpp_runtime_unhandled_exception_policy_set :: proc (policy: i32) {
	resolve(proc "c" (i32), "il2cpp_runtime_unhandled_exception_policy_set")(policy)
}

// --- string ----------------------------------------------------------------

vm_il2cpp_string_length :: proc (str: Il2CppString) -> i32 {
	return resolve(proc "c" (Il2CppString) -> i32, "il2cpp_string_length")(str)
}

vm_il2cpp_string_chars :: proc (str: Il2CppString) -> ^u16 {
	return resolve(proc "c" (Il2CppString) -> ^u16, "il2cpp_string_chars")(str)
}

vm_il2cpp_string_new :: proc (str: cstring) -> Il2CppString {
	return resolve(proc "c" (cstring) -> Il2CppString, "il2cpp_string_new")(str)
}

vm_il2cpp_string_new_len :: proc (str: cstring, length: u32) -> Il2CppString {
	return resolve(
		proc "c" (cstring, u32) -> Il2CppString,
		"il2cpp_string_new_len",
	)(str, length)
}

vm_il2cpp_string_new_utf16 :: proc (text: ^u16, length: i32) -> Il2CppString {
	return resolve(
		proc "c" (^u16, i32) -> Il2CppString,
		"il2cpp_string_new_utf16",
	)(text, length)
}

vm_il2cpp_string_new_wrapper :: proc (str: cstring) -> Il2CppString {
	return resolve(proc "c" (cstring) -> Il2CppString, "il2cpp_string_new_wrapper")(str)
}

vm_il2cpp_string_intern :: proc (str: Il2CppString) -> Il2CppString {
	return resolve(proc "c" (Il2CppString) -> Il2CppString, "il2cpp_string_intern")(str)
}

vm_il2cpp_string_is_interned :: proc (str: Il2CppString) -> bool {
	return resolve(proc "c" (Il2CppString) -> bool, "il2cpp_string_is_interned")(str)
}

// --- thread ----------------------------------------------------------------

vm_il2cpp_thread_current :: proc () -> Il2CppThread {
	return resolve(proc "c" () -> Il2CppThread, "il2cpp_thread_current")()
}

vm_il2cpp_thread_attach :: proc (domain: Il2CppDomain) -> Il2CppThread {
	return resolve(proc "c" (Il2CppDomain) -> Il2CppThread, "il2cpp_thread_attach")(domain)
}

vm_il2cpp_thread_detach :: proc (thread: Il2CppThread) {
	resolve(proc "c" (Il2CppThread), "il2cpp_thread_detach")(thread)
}

vm_il2cpp_is_vm_thread :: proc () -> bool {
	return resolve(proc "c" () -> bool, "il2cpp_is_vm_thread")()
}

vm_il2cpp_current_thread_walk_frame_stack :: proc (cb: rawptr, user_data: rawptr) {
	resolve(
		proc "c" (rawptr, rawptr),
		"il2cpp_current_thread_walk_frame_stack",
	)(cb, user_data)
}

vm_il2cpp_thread_walk_frame_stack :: proc (
	thread:    Il2CppThread,
	cb:        rawptr,
	user_data: rawptr,
) {
	resolve(
		proc "c" (Il2CppThread, rawptr, rawptr),
		"il2cpp_thread_walk_frame_stack",
	)(thread, cb, user_data)
}

vm_il2cpp_current_thread_get_top_frame :: proc () -> ^Il2CppStackFrameInfo {
	f := resolve(
		proc "c" () -> ^Il2CppStackFrameInfo,
		"il2cpp_current_thread_get_top_frame",
	)
	return f()
}

vm_il2cpp_thread_get_top_frame :: proc (thread: Il2CppThread) -> ^Il2CppStackFrameInfo {
	return resolve(
		proc "c" (Il2CppThread) -> ^Il2CppStackFrameInfo,
		"il2cpp_thread_get_top_frame",
	)(thread)
}

vm_il2cpp_current_thread_get_frame_at :: proc (offset: i32) -> ^Il2CppStackFrameInfo {
	return resolve(
		proc "c" (i32) -> ^Il2CppStackFrameInfo,
		"il2cpp_current_thread_get_frame_at",
	)(offset)
}

vm_il2cpp_thread_get_frame_at :: proc (
	thread: Il2CppThread,
	offset: i32,
) -> ^Il2CppStackFrameInfo {
	return resolve(
		proc "c" (Il2CppThread, i32) -> ^Il2CppStackFrameInfo,
		"il2cpp_thread_get_frame_at",
	)(thread, offset)
}

vm_il2cpp_current_thread_get_stack_depth :: proc () -> i32 {
	return resolve(proc "c" () -> i32, "il2cpp_current_thread_get_stack_depth")()
}

vm_il2cpp_thread_get_stack_depth :: proc (thread: Il2CppThread) -> i32 {
	return resolve(proc "c" (Il2CppThread) -> i32, "il2cpp_thread_get_stack_depth")(thread)
}

vm_il2cpp_override_stack_backtrace :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_override_stack_backtrace")(cb)
}

// --- type ----------------------------------------------------------------

vm_il2cpp_type_get_object :: proc (t: Il2CppType) -> Il2CppObject {
	return resolve(proc "c" (Il2CppType) -> Il2CppObject, "il2cpp_type_get_object")(t)
}

vm_il2cpp_type_get_type :: proc (t: Il2CppType) -> i32 {
	return resolve(proc "c" (Il2CppType) -> i32, "il2cpp_type_get_type")(t)
}

vm_il2cpp_type_get_class_or_element_class :: proc (t: Il2CppType) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppType) -> Il2CppClass,
		"il2cpp_type_get_class_or_element_class",
	)(t)
}

vm_il2cpp_type_get_name :: proc (t: Il2CppType) -> cstring {
	return resolve(proc "c" (Il2CppType) -> cstring, "il2cpp_type_get_name")(t)
}

vm_il2cpp_type_is_byref :: proc (t: Il2CppType) -> bool {
	return resolve(proc "c" (Il2CppType) -> bool, "il2cpp_type_is_byref")(t)
}

vm_il2cpp_type_get_attrs :: proc (t: Il2CppType) -> u32 {
	return resolve(proc "c" (Il2CppType) -> u32, "il2cpp_type_get_attrs")(t)
}

vm_il2cpp_type_equals :: proc (a: Il2CppType, b: Il2CppType) -> bool {
	return resolve(proc "c" (Il2CppType, Il2CppType) -> bool, "il2cpp_type_equals")(a, b)
}

vm_il2cpp_type_get_assembly_qualified_name :: proc (t: Il2CppType) -> cstring {
	return resolve(
		proc "c" (Il2CppType) -> cstring,
		"il2cpp_type_get_assembly_qualified_name",
	)(t)
}

vm_il2cpp_type_get_reflection_name :: proc (t: Il2CppType) -> cstring {
	return resolve(proc "c" (Il2CppType) -> cstring, "il2cpp_type_get_reflection_name")(t)
}

vm_il2cpp_type_is_static :: proc (t: Il2CppType) -> bool {
	return resolve(proc "c" (Il2CppType) -> bool, "il2cpp_type_is_static")(t)
}

vm_il2cpp_type_is_pointer_type :: proc (t: Il2CppType) -> bool {
	return resolve(proc "c" (Il2CppType) -> bool, "il2cpp_type_is_pointer_type")(t)
}

// --- misc (memory snapshot, callbacks, debugger, custom attrs) ---------------

vm_il2cpp_capture_memory_snapshot :: proc (snapshot: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_capture_memory_snapshot")(snapshot)
}

vm_il2cpp_free_captured_memory_snapshot :: proc (snapshot: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_free_captured_memory_snapshot")(snapshot)
}

vm_il2cpp_set_find_plugin_callback :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_set_find_plugin_callback")(cb)
}

vm_il2cpp_register_log_callback :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_register_log_callback")(cb)
}

vm_il2cpp_debugger_set_agent_options :: proc (options: cstring) {
	resolve(proc "c" (cstring), "il2cpp_debugger_set_agent_options")(options)
}

vm_il2cpp_is_debugger_attached :: proc () -> bool {
	return resolve(proc "c" () -> bool, "il2cpp_is_debugger_attached")()
}

vm_il2cpp_register_debugger_agent_transport :: proc (transport: rawptr, timeout: i64) {
	resolve(
		proc "c" (rawptr, i64),
		"il2cpp_register_debugger_agent_transport",
	)(transport, timeout)
}

vm_il2cpp_debug_foreach_method :: proc (visit: rawptr, user_data: rawptr) {
	resolve(proc "c" (rawptr, rawptr), "il2cpp_debug_foreach_method")(visit, user_data)
}

vm_il2cpp_debug_get_method_info :: proc (method: Il2CppMethod) -> rawptr {
	return resolve(
		proc "c" (Il2CppMethod) -> rawptr,
		"il2cpp_debug_get_method_info",
	)(method)
}

vm_il2cpp_unity_install_unitytls_interface :: proc (iface: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_unity_install_unitytls_interface")(iface)
}

vm_il2cpp_custom_attrs_from_class :: proc (class: Il2CppClass) -> rawptr {
	return resolve(
		proc "c" (Il2CppClass) -> rawptr,
		"il2cpp_custom_attrs_from_class",
	)(class)
}

vm_il2cpp_custom_attrs_from_method :: proc (method: Il2CppMethod) -> rawptr {
	return resolve(
		proc "c" (Il2CppMethod) -> rawptr,
		"il2cpp_custom_attrs_from_method",
	)(method)
}

vm_il2cpp_custom_attrs_from_field :: proc (
	class: Il2CppClass,
	field: Il2CppField,
) -> rawptr {
	return resolve(
		proc "c" (Il2CppClass, Il2CppField) -> rawptr,
		"il2cpp_custom_attrs_from_field",
	)(class, field)
}

vm_il2cpp_custom_attrs_get_attr :: proc (attrs: rawptr, attr_class: Il2CppClass) -> rawptr {
	return resolve(
		proc "c" (rawptr, Il2CppClass) -> rawptr,
		"il2cpp_custom_attrs_get_attr",
	)(attrs, attr_class)
}

vm_il2cpp_custom_attrs_has_attr :: proc (attrs: rawptr, attr_class: Il2CppClass) -> bool {
	return resolve(
		proc "c" (rawptr, Il2CppClass) -> bool,
		"il2cpp_custom_attrs_has_attr",
	)(attrs, attr_class)
}

vm_il2cpp_custom_attrs_construct :: proc (attrs: rawptr) -> Il2CppObject {
	return resolve(
		proc "c" (rawptr) -> Il2CppObject,
		"il2cpp_custom_attrs_construct",
	)(attrs)
}

vm_il2cpp_custom_attrs_free :: proc (attrs: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_custom_attrs_free")(attrs)
}

vm_il2cpp_class_set_userdata :: proc (class: Il2CppClass, userdata: rawptr) {
	resolve(proc "c" (Il2CppClass, rawptr), "il2cpp_class_set_userdata")(class, userdata)
}

vm_il2cpp_class_get_userdata_offset :: proc () -> i32 {
	return resolve(proc "c" () -> i32, "il2cpp_class_get_userdata_offset")()
}

vm_il2cpp_set_default_thread_affinity :: proc (mask: i64) {
	resolve(proc "c" (i64), "il2cpp_set_default_thread_affinity")(mask)
}

vm_il2cpp_unity_set_android_network_up_state_func :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), "il2cpp_unity_set_android_network_up_state_func")(cb)
}
