package il2cpp

// resolve fetches a typed proc from the api cache.
// returns a nil proc if the export is missing.
// calling a nil proc crashes, so only call vm_*
// after GameAssembly.dll is mapped (or il2cpp.init ran)
resolve :: proc ($T: typeid, name: string) -> T {
	p := api(name)
	if p == nil {
		return {}
	}
	return cast(T)p
}

// --- lifecycle ----------------------------------------------------------

vm_il2cpp_init :: proc (domain_name: cstring) {
	resolve(proc "c" (cstring), IL2CPP_INIT)(domain_name)
}

vm_il2cpp_init_utf16 :: proc (domain_name: cstring16) -> Il2CppDomain {
	return resolve(proc "c" (cstring16) -> Il2CppDomain, IL2CPP_INIT_UTF16)(domain_name)
}

vm_il2cpp_shutdown :: proc () {
	resolve(proc "c" (), IL2CPP_SHUTDOWN)()
}

vm_il2cpp_set_config_dir :: proc (dir: cstring) {
	resolve(proc "c" (cstring), IL2CPP_SET_CONFIG_DIR)(dir)
}

vm_il2cpp_set_data_dir :: proc (dir: cstring) {
	resolve(proc "c" (cstring), IL2CPP_SET_DATA_DIR)(dir)
}

vm_il2cpp_set_temp_dir :: proc (dir: cstring) {
	resolve(proc "c" (cstring), IL2CPP_SET_TEMP_DIR)(dir)
}

vm_il2cpp_set_commandline_arguments :: proc (argc: i32, argv: ^^cstring, basedir: cstring) {
	resolve(
		proc "c" (i32, ^^cstring, cstring),
		IL2CPP_SET_COMMANDLINE_ARGUMENTS,
	)(argc, argv, basedir)
}

vm_il2cpp_set_commandline_arguments_utf16 :: proc (
	argc:    i32,
	argv:    ^^cstring,
	basedir: cstring,
) {
	resolve(proc "c" (i32, ^^cstring, cstring),
		IL2CPP_SET_COMMANDLINE_ARGUMENTS_UTF16)(argc, argv, basedir)
}

vm_il2cpp_set_config :: proc (key: cstring, value: cstring) {
	resolve(proc "c" (cstring, cstring), IL2CPP_SET_CONFIG)(key, value)
}

vm_il2cpp_set_config_utf16 :: proc (key: cstring16, value: cstring16) {
	resolve(proc "c" (cstring16, cstring16), IL2CPP_SET_CONFIG_UTF16)(key, value)
}

vm_il2cpp_set_memory_callbacks :: proc (cbs: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_SET_MEMORY_CALLBACKS)(cbs)
}

vm_il2cpp_memory_pool_set_region_size :: proc (size: uintptr) {
	resolve(proc "c" (uintptr), IL2CPP_MEMORY_POOL_SET_REGION_SIZE)(size)
}

vm_il2cpp_memory_pool_get_region_size :: proc () -> uintptr {
	return resolve(proc "c" () -> uintptr, IL2CPP_MEMORY_POOL_GET_REGION_SIZE)()
}

vm_il2cpp_get_corlib :: proc () -> Il2CppImage {
	return resolve(proc "c" () -> Il2CppImage, IL2CPP_GET_CORLIB)()
}

vm_il2cpp_add_internal_call :: proc (name: cstring, method: rawptr) {
	resolve(proc "c" (cstring, rawptr), IL2CPP_ADD_INTERNAL_CALL)(name, method)
}

vm_il2cpp_resolve_icall :: proc (name: cstring) -> rawptr {
	return resolve(proc "c" (cstring) -> rawptr, IL2CPP_RESOLVE_ICALL)(name)
}

vm_il2cpp_alloc :: proc (size: uintptr) -> rawptr {
	return resolve(proc "c" (uintptr) -> rawptr, IL2CPP_ALLOC)(size)
}

vm_il2cpp_free :: proc (p: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_FREE)(p)
}

// --- arrays --------------------------------------------------------------

vm_il2cpp_array_class_get :: proc (element_class: Il2CppClass, rank: u32) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppClass, u32) -> Il2CppClass,
		IL2CPP_ARRAY_CLASS_GET,
	)(element_class, rank)
}

vm_il2cpp_array_length :: proc (array: Il2CppArray) -> uintptr {
	return resolve(proc "c" (Il2CppArray) -> uintptr, IL2CPP_ARRAY_LENGTH)(array)
}

vm_il2cpp_array_get_byte_length :: proc (array: Il2CppArray) -> u32 {
	return resolve(proc "c" (Il2CppArray) -> u32, IL2CPP_ARRAY_GET_BYTE_LENGTH)(array)
}

vm_il2cpp_array_new :: proc (element_class: Il2CppClass, length: uintptr) -> Il2CppArray {
	return resolve(
		proc "c" (Il2CppClass, uintptr) -> Il2CppArray,
		IL2CPP_ARRAY_NEW,
	)(element_class, length)
}

vm_il2cpp_array_new_specific :: proc (
	array_class: Il2CppClass,
	length:      uintptr,
) -> Il2CppArray {
	return resolve(
		proc "c" (Il2CppClass, uintptr) -> Il2CppArray,
		IL2CPP_ARRAY_NEW_SPECIFIC,
	)(array_class, length)
}

vm_il2cpp_array_new_full :: proc (
	array_class:  Il2CppClass,
	lengths:      ^uintptr,
	lower_bounds: ^uintptr,
) -> Il2CppArray {
	return resolve(
		proc "c" (Il2CppClass, ^uintptr, ^uintptr) -> Il2CppArray,
		IL2CPP_ARRAY_NEW_FULL,
	)(array_class, lengths, lower_bounds)
}

vm_il2cpp_bounded_array_class_get :: proc (
	element_class: Il2CppClass,
	rank:          u32,
	bounded:       bool,
) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppClass, u32, bool) -> Il2CppClass,
		IL2CPP_BOUNDED_ARRAY_CLASS_GET,
	)(element_class, rank, bounded)
}

vm_il2cpp_array_element_size :: proc (array_class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, IL2CPP_ARRAY_ELEMENT_SIZE)(array_class)
}

// --- asm / image ----------------------------------------------------------

vm_il2cpp_assembly_get_image :: proc (assembly: Il2CppAssembly) -> Il2CppImage {
	return resolve(
		proc "c" (Il2CppAssembly) -> Il2CppImage,
		IL2CPP_ASSEMBLY_GET_IMAGE,
	)(assembly)
}

vm_il2cpp_image_get_assembly :: proc (image: Il2CppImage) -> Il2CppAssembly {
	return resolve(
		proc "c" (Il2CppImage) -> Il2CppAssembly,
		IL2CPP_IMAGE_GET_ASSEMBLY,
	)(image)
}

vm_il2cpp_image_get_name :: proc (image: Il2CppImage) -> cstring {
	return resolve(proc "c" (Il2CppImage) -> cstring, IL2CPP_IMAGE_GET_NAME)(image)
}

vm_il2cpp_image_get_filename :: proc (image: Il2CppImage) -> cstring {
	return resolve(proc "c" (Il2CppImage) -> cstring, IL2CPP_IMAGE_GET_FILENAME)(image)
}

vm_il2cpp_image_get_entry_point :: proc (image: Il2CppImage) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppImage) -> Il2CppMethod,
		IL2CPP_IMAGE_GET_ENTRY_POINT,
	)(image)
}

vm_il2cpp_image_get_class_count :: proc (image: Il2CppImage) -> uintptr {
	return resolve(proc "c" (Il2CppImage) -> uintptr, IL2CPP_IMAGE_GET_CLASS_COUNT)(image)
}

vm_il2cpp_image_get_class :: proc (image: Il2CppImage, index: uintptr) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppImage, uintptr) -> Il2CppClass,
		IL2CPP_IMAGE_GET_CLASS,
	)(image, index)
}

// --- class ---------------------------------------------------------------

vm_il2cpp_class_for_each :: proc (visit: rawptr, user_data: rawptr) {
	resolve(proc "c" (rawptr, rawptr), IL2CPP_CLASS_FOR_EACH)(visit, user_data)
}

vm_il2cpp_class_enum_basetype :: proc (class: Il2CppClass) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppClass) -> Il2CppType,
		IL2CPP_CLASS_ENUM_BASETYPE,
	)(class)
}

vm_il2cpp_class_is_inited :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, IL2CPP_CLASS_IS_INITED)(class)
}

vm_il2cpp_class_is_generic :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, IL2CPP_CLASS_IS_GENERIC)(class)
}

vm_il2cpp_class_is_inflated :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, IL2CPP_CLASS_IS_INFLATED)(class)
}

vm_il2cpp_class_is_assignable_from :: proc (
	class: Il2CppClass,
	other: Il2CppClass,
) -> bool {
	return resolve(
		proc "c" (Il2CppClass, Il2CppClass) -> bool,
		IL2CPP_CLASS_IS_ASSIGNABLE_FROM,
	)(class, other)
}

vm_il2cpp_class_is_subclass_of :: proc (
	class:            Il2CppClass,
	base:             Il2CppClass,
	check_interfaces: bool,
) -> bool {
	return resolve(
		proc "c" (Il2CppClass, Il2CppClass, bool) -> bool,
		IL2CPP_CLASS_IS_SUBCLASS_OF,
	)(class, base, check_interfaces)
}

vm_il2cpp_class_has_parent :: proc (class: Il2CppClass, parent: Il2CppClass) -> bool {
	return resolve(
		proc "c" (Il2CppClass, Il2CppClass) -> bool,
		IL2CPP_CLASS_HAS_PARENT,
	)(class, parent)
}

vm_il2cpp_class_from_il2cpp_type :: proc (t: Il2CppType) -> Il2CppClass {
	return resolve(proc "c" (Il2CppType) -> Il2CppClass, IL2CPP_CLASS_FROM_IL2CPP_TYPE)(t)
}

vm_il2cpp_class_from_name :: proc (
	image:      Il2CppImage,
	namespace: cstring,
	name:       cstring,
) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppImage, cstring, cstring) -> Il2CppClass,
		IL2CPP_CLASS_FROM_NAME,
	)(image, namespace, name)
}

vm_il2cpp_class_from_system_type :: proc (t: Il2CppObject) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppObject) -> Il2CppClass,
		IL2CPP_CLASS_FROM_SYSTEM_TYPE,
	)(t)
}

vm_il2cpp_class_get_element_class :: proc (class: Il2CppClass) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppClass) -> Il2CppClass,
		IL2CPP_CLASS_GET_ELEMENT_CLASS,
	)(class)
}

vm_il2cpp_class_get_events :: proc (class: Il2CppClass, iter: ^rawptr) -> Il2CppEventInfo {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppEventInfo,
		IL2CPP_CLASS_GET_EVENTS,
	)(class, iter)
}

vm_il2cpp_class_get_fields :: proc (class: Il2CppClass, iter: ^rawptr) -> Il2CppField {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppField,
		IL2CPP_CLASS_GET_FIELDS,
	)(class, iter)
}

vm_il2cpp_class_get_nested_types :: proc (
	class: Il2CppClass,
	iter:  ^rawptr,
) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppClass,
		IL2CPP_CLASS_GET_NESTED_TYPES,
	)(class, iter)
}

vm_il2cpp_class_get_interfaces :: proc (class: Il2CppClass, iter: ^rawptr) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppType,
		IL2CPP_CLASS_GET_INTERFACES,
	)(class, iter)
}

vm_il2cpp_class_get_properties :: proc (
	class: Il2CppClass,
	iter:  ^rawptr,
) -> Il2CppProperty {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppProperty,
		IL2CPP_CLASS_GET_PROPERTIES,
	)(class, iter)
}

vm_il2cpp_class_get_property_from_name :: proc (
	class: Il2CppClass,
	name:  cstring,
) -> Il2CppProperty {
	return resolve(
		proc "c" (Il2CppClass, cstring) -> Il2CppProperty,
		IL2CPP_CLASS_GET_PROPERTY_FROM_NAME,
	)(class, name)
}

vm_il2cpp_class_get_field_from_name :: proc (
	class: Il2CppClass,
	name:  cstring,
) -> Il2CppField {
	return resolve(
		proc "c" (Il2CppClass, cstring) -> Il2CppField,
		IL2CPP_CLASS_GET_FIELD_FROM_NAME,
	)(class, name)
}

vm_il2cpp_class_get_methods :: proc (class: Il2CppClass, iter: ^rawptr) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppClass, ^rawptr) -> Il2CppMethod,
		IL2CPP_CLASS_GET_METHODS,
	)(class, iter)
}

vm_il2cpp_class_get_method_from_name :: proc (
	class:     Il2CppClass,
	name:      cstring,
	arg_count: i32,
) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppClass, cstring, i32) -> Il2CppMethod,
		IL2CPP_CLASS_GET_METHOD_FROM_NAME,
	)(class, name, arg_count)
}

vm_il2cpp_class_get_name :: proc (class: Il2CppClass) -> cstring {
	return resolve(proc "c" (Il2CppClass) -> cstring, IL2CPP_CLASS_GET_NAME)(class)
}

vm_il2cpp_class_get_namespace :: proc (class: Il2CppClass) -> cstring {
	return resolve(proc "c" (Il2CppClass) -> cstring, IL2CPP_CLASS_GET_NAMESPACE)(class)
}

vm_il2cpp_class_get_parent :: proc (class: Il2CppClass) -> Il2CppClass {
	return resolve(proc "c" (Il2CppClass) -> Il2CppClass, IL2CPP_CLASS_GET_PARENT)(class)
}

vm_il2cpp_class_get_declaring_type :: proc (class: Il2CppClass) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppClass) -> Il2CppType,
		IL2CPP_CLASS_GET_DECLARING_TYPE,
	)(class)
}

vm_il2cpp_class_instance_size :: proc (class: Il2CppClass) -> i32 {
	return resolve(proc "c" (Il2CppClass) -> i32, IL2CPP_CLASS_INSTANCE_SIZE)(class)
}

vm_il2cpp_class_num_fields :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, IL2CPP_CLASS_NUM_FIELDS)(class)
}

vm_il2cpp_class_is_valuetype :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, IL2CPP_CLASS_IS_VALUETYPE)(class)
}

vm_il2cpp_class_value_size :: proc (class: Il2CppClass, align: ^u32) -> u32 {
	return resolve(
		proc "c" (Il2CppClass, ^u32) -> u32,
		IL2CPP_CLASS_VALUE_SIZE,
	)(class, align)
}

vm_il2cpp_class_is_blittable :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, IL2CPP_CLASS_IS_BLITTABLE)(class)
}

vm_il2cpp_class_get_flags :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, IL2CPP_CLASS_GET_FLAGS)(class)
}

vm_il2cpp_class_is_abstract :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, IL2CPP_CLASS_IS_ABSTRACT)(class)
}

vm_il2cpp_class_is_interface :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, IL2CPP_CLASS_IS_INTERFACE)(class)
}

vm_il2cpp_class_array_element_size :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, IL2CPP_CLASS_ARRAY_ELEMENT_SIZE)(class)
}

vm_il2cpp_class_from_type :: proc (t: Il2CppType) -> Il2CppClass {
	return resolve(proc "c" (Il2CppType) -> Il2CppClass, IL2CPP_CLASS_FROM_TYPE)(t)
}

vm_il2cpp_class_get_type :: proc (class: Il2CppClass) -> Il2CppType {
	return resolve(proc "c" (Il2CppClass) -> Il2CppType, IL2CPP_CLASS_GET_TYPE)(class)
}

vm_il2cpp_class_get_type_token :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, IL2CPP_CLASS_GET_TYPE_TOKEN)(class)
}

vm_il2cpp_class_has_attribute :: proc (class: Il2CppClass, attr: Il2CppClass) -> bool {
	return resolve(
		proc "c" (Il2CppClass, Il2CppClass) -> bool,
		IL2CPP_CLASS_HAS_ATTRIBUTE,
	)(class, attr)
}

vm_il2cpp_class_has_references :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, IL2CPP_CLASS_HAS_REFERENCES)(class)
}

vm_il2cpp_class_is_enum :: proc (class: Il2CppClass) -> bool {
	return resolve(proc "c" (Il2CppClass) -> bool, IL2CPP_CLASS_IS_ENUM)(class)
}

vm_il2cpp_class_get_image :: proc (class: Il2CppClass) -> Il2CppImage {
	return resolve(proc "c" (Il2CppClass) -> Il2CppImage, IL2CPP_CLASS_GET_IMAGE)(class)
}

vm_il2cpp_class_get_assemblyname :: proc (class: Il2CppClass) -> cstring {
	return resolve(
		proc "c" (Il2CppClass) -> cstring,
		IL2CPP_CLASS_GET_ASSEMBLYNAME,
	)(class)
}

vm_il2cpp_class_get_rank :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, IL2CPP_CLASS_GET_RANK)(class)
}

vm_il2cpp_class_get_data_size :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, IL2CPP_CLASS_GET_DATA_SIZE)(class)
}

vm_il2cpp_class_get_static_field_data :: proc (class: Il2CppClass) -> rawptr {
	return resolve(
		proc "c" (Il2CppClass) -> rawptr,
		IL2CPP_CLASS_GET_STATIC_FIELD_DATA,
	)(class)
}

// --- stats ----------------------------------------------------------------

vm_il2cpp_stats_dump_to_file :: proc (path: cstring) -> i32 {
	return resolve(proc "c" (cstring) -> i32, IL2CPP_STATS_DUMP_TO_FILE)(path)
}

vm_il2cpp_stats_get_value :: proc (counter: u32) -> i64 {
	return resolve(proc "c" (u32) -> i64, IL2CPP_STATS_GET_VALUE)(counter)
}

// --- domain ---------------------------------------------------------------

vm_il2cpp_domain_get :: proc () -> Il2CppDomain {
	return resolve(proc "c" () -> Il2CppDomain, IL2CPP_DOMAIN_GET)()
}

vm_il2cpp_domain_assembly_open :: proc (
	domain: Il2CppDomain,
	name:   cstring,
) -> Il2CppAssembly {
	return resolve(
		proc "c" (Il2CppDomain, cstring) -> Il2CppAssembly,
		IL2CPP_DOMAIN_ASSEMBLY_OPEN,
	)(domain, name)
}

vm_il2cpp_domain_get_assemblies :: proc (
	domain: Il2CppDomain,
	count:  ^uintptr,
) -> [^]Il2CppAssembly {
	return resolve(
		proc "c" (Il2CppDomain, ^uintptr) -> [^]Il2CppAssembly,
		IL2CPP_DOMAIN_GET_ASSEMBLIES,
	)(domain, count)
}

// --- exceptions ------------------------------------------------------------

vm_il2cpp_raise_exception :: proc (ex: Il2CppException) -> ! {
	resolve(proc "c" (Il2CppException), IL2CPP_RAISE_EXCEPTION)(ex)
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
		IL2CPP_EXCEPTION_FROM_NAME_MSG,
	)(image, namespace, name, msg)
}

vm_il2cpp_get_exception_argument_null :: proc (arg: cstring) -> Il2CppException {
	return resolve(
		proc "c" (cstring) -> Il2CppException,
		IL2CPP_GET_EXCEPTION_ARGUMENT_NULL,
	)(arg)
}

vm_il2cpp_format_exception :: proc (ex: Il2CppException) -> cstring {
	return resolve(proc "c" (Il2CppException) -> cstring, IL2CPP_FORMAT_EXCEPTION)(ex)
}

vm_il2cpp_format_stack_trace :: proc (ex: Il2CppException) -> cstring {
	return resolve(proc "c" (Il2CppException) -> cstring, IL2CPP_FORMAT_STACK_TRACE)(ex)
}

vm_il2cpp_unhandled_exception :: proc (ex: Il2CppException) -> ! {
	resolve(proc "c" (Il2CppException), IL2CPP_UNHANDLED_EXCEPTION)(ex)
	unreachable()
}

vm_il2cpp_native_stack_trace :: proc (frames: ^Il2CppStackFrameInfo, frame_count: u32) {
	resolve(
		proc "c" (^Il2CppStackFrameInfo, u32),
		IL2CPP_NATIVE_STACK_TRACE,
	)(frames, frame_count)
}

// --- fields ----------------------------------------------------------------

vm_il2cpp_field_get_flags :: proc (field: Il2CppField) -> u32 {
	return resolve(proc "c" (Il2CppField) -> u32, IL2CPP_FIELD_GET_FLAGS)(field)
}

vm_il2cpp_field_get_from_reflection :: proc (obj: Il2CppObject) -> Il2CppField {
	return resolve(
		proc "c" (Il2CppObject) -> Il2CppField,
		IL2CPP_FIELD_GET_FROM_REFLECTION,
	)(obj)
}

vm_il2cpp_field_get_name :: proc (field: Il2CppField) -> cstring {
	return resolve(proc "c" (Il2CppField) -> cstring, IL2CPP_FIELD_GET_NAME)(field)
}

vm_il2cpp_field_get_parent :: proc (field: Il2CppField) -> Il2CppClass {
	return resolve(proc "c" (Il2CppField) -> Il2CppClass, IL2CPP_FIELD_GET_PARENT)(field)
}

vm_il2cpp_field_get_object :: proc (
	obj:   Il2CppObject,
	field: Il2CppField,
	value: ^rawptr,
) -> Il2CppObject {
	return resolve(
		proc "c" (Il2CppObject, Il2CppField, ^rawptr) -> Il2CppObject,
		IL2CPP_FIELD_GET_OBJECT,
	)(obj, field, value)
}

vm_il2cpp_field_get_offset :: proc (field: Il2CppField) -> uintptr {
	return resolve(proc "c" (Il2CppField) -> uintptr, IL2CPP_FIELD_GET_OFFSET)(field)
}

vm_il2cpp_field_get_type :: proc (field: Il2CppField) -> Il2CppType {
	return resolve(proc "c" (Il2CppField) -> Il2CppType, IL2CPP_FIELD_GET_TYPE)(field)
}

vm_il2cpp_field_get_value :: proc (obj: Il2CppObject, field: Il2CppField, value: rawptr) {
	resolve(
		proc "c" (Il2CppObject, Il2CppField, rawptr),
		IL2CPP_FIELD_GET_VALUE,
	)(obj, field, value)
}

vm_il2cpp_field_get_value_object :: proc (
	field: Il2CppField,
	obj:   Il2CppObject,
	class: Il2CppClass,
) -> Il2CppObject {
	return resolve(
		proc "c" (Il2CppField, Il2CppObject, Il2CppClass) -> Il2CppObject,
		IL2CPP_FIELD_GET_VALUE_OBJECT,
	)(field, obj, class)
}

vm_il2cpp_field_has_attribute :: proc (field: Il2CppField, attr: Il2CppClass) -> bool {
	return resolve(
		proc "c" (Il2CppField, Il2CppClass) -> bool,
		IL2CPP_FIELD_HAS_ATTRIBUTE,
	)(field, attr)
}

vm_il2cpp_field_set_value :: proc (obj: Il2CppObject, field: Il2CppField, value: rawptr) {
	resolve(
		proc "c" (Il2CppObject, Il2CppField, rawptr),
		IL2CPP_FIELD_SET_VALUE,
	)(obj, field, value)
}

vm_il2cpp_field_static_get_value :: proc (field: Il2CppField, value: rawptr) {
	resolve(proc "c" (Il2CppField, rawptr), IL2CPP_FIELD_STATIC_GET_VALUE)(field, value)
}

vm_il2cpp_field_static_set_value :: proc (field: Il2CppField, value: rawptr) {
	resolve(proc "c" (Il2CppField, rawptr), IL2CPP_FIELD_STATIC_SET_VALUE)(field, value)
}

vm_il2cpp_field_set_value_object :: proc (
	class: Il2CppClass,
	obj:   Il2CppObject,
	field: Il2CppField,
	value: Il2CppObject,
) {
	resolve(
		proc "c" (Il2CppClass, Il2CppObject, Il2CppField, Il2CppObject),
		IL2CPP_FIELD_SET_VALUE_OBJECT,
	)(class, obj, field, value)
}

vm_il2cpp_field_is_literal :: proc (field: Il2CppField) -> bool {
	return resolve(proc "c" (Il2CppField) -> bool, IL2CPP_FIELD_IS_LITERAL)(field)
}

// --- gc --------------------------------------------------------------------

vm_il2cpp_gc_collect :: proc (force: i32) {
	resolve(proc "c" (i32), IL2CPP_GC_COLLECT)(force)
}

vm_il2cpp_gc_collect_a_little :: proc () {
	resolve(proc "c" (), IL2CPP_GC_COLLECT_A_LITTLE)()
}

vm_il2cpp_gc_start_incremental_collection :: proc () {
	resolve(proc "c" (), IL2CPP_GC_START_INCREMENTAL_COLLECTION)()
}

vm_il2cpp_gc_disable :: proc () {
	resolve(proc "c" (), IL2CPP_GC_DISABLE)()
}

vm_il2cpp_gc_enable :: proc () {
	resolve(proc "c" (), IL2CPP_GC_ENABLE)()
}

vm_il2cpp_gc_is_disabled :: proc () -> bool {
	return resolve(proc "c" () -> bool, IL2CPP_GC_IS_DISABLED)()
}

vm_il2cpp_gc_set_mode :: proc (mode: i32) {
	resolve(proc "c" (i32), IL2CPP_GC_SET_MODE)(mode)
}

vm_il2cpp_gc_get_max_time_slice_ns :: proc () -> i64 {
	return resolve(proc "c" () -> i64, IL2CPP_GC_GET_MAX_TIME_SLICE_NS)()
}

vm_il2cpp_gc_set_max_time_slice_ns :: proc (ns: i64) {
	resolve(proc "c" (i64), IL2CPP_GC_SET_MAX_TIME_SLICE_NS)(ns)
}

vm_il2cpp_gc_is_incremental :: proc () -> bool {
	return resolve(proc "c" () -> bool, IL2CPP_GC_IS_INCREMENTAL)()
}

vm_il2cpp_gc_get_used_size :: proc () -> i64 {
	return resolve(proc "c" () -> i64, IL2CPP_GC_GET_USED_SIZE)()
}

vm_il2cpp_gc_get_heap_size :: proc () -> i64 {
	return resolve(proc "c" () -> i64, IL2CPP_GC_GET_HEAP_SIZE)()
}

vm_il2cpp_gc_wbarrier_set_field :: proc (
	obj:    Il2CppObject,
	target: ^rawptr,
	value:  Il2CppObject,
) {
	resolve(
		proc "c" (Il2CppObject, ^rawptr, Il2CppObject),
		IL2CPP_GC_WBARRIER_SET_FIELD,
	)(obj, target, value)
}

vm_il2cpp_gc_has_strict_wbarriers :: proc () -> bool {
	return resolve(proc "c" () -> bool, IL2CPP_GC_HAS_STRICT_WBARRIERS)()
}

vm_il2cpp_gc_set_external_allocation_tracker :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_GC_SET_EXTERNAL_ALLOCATION_TRACKER)(cb)
}

vm_il2cpp_gc_set_external_wbarrier_tracker :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_GC_SET_EXTERNAL_WBARRIER_TRACKER)(cb)
}

vm_il2cpp_gc_foreach_heap :: proc (cb: rawptr, user_data: rawptr) {
	resolve(proc "c" (rawptr, rawptr), IL2CPP_GC_FOREACH_HEAP)(cb, user_data)
}

vm_il2cpp_stop_gc_world :: proc (force: i32) {
	resolve(proc "c" (i32), IL2CPP_STOP_GC_WORLD)(force)
}

vm_il2cpp_start_gc_world :: proc () {
	resolve(proc "c" (), IL2CPP_START_GC_WORLD)()
}

vm_il2cpp_gc_alloc_fixed :: proc (size: uintptr, offset: uintptr) -> rawptr {
	return resolve(
		proc "c" (uintptr, uintptr) -> rawptr,
		IL2CPP_GC_ALLOC_FIXED,
	)(size, offset)
}

vm_il2cpp_gc_free_fixed :: proc (p: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_GC_FREE_FIXED)(p)
}

// --- gchandle ----------------------------------------------------------------

vm_il2cpp_gchandle_new :: proc (obj: Il2CppObject, pinned: bool) -> GCHandle {
	return resolve(
		proc "c" (Il2CppObject, bool) -> GCHandle,
		IL2CPP_GCHANDLE_NEW,
	)(obj, pinned)
}

vm_il2cpp_gchandle_new_weakref :: proc (
	obj:                Il2CppObject,
	track_resurrection: bool,
) -> GCHandle {
	return resolve(
		proc "c" (Il2CppObject, bool) -> GCHandle,
		IL2CPP_GCHANDLE_NEW_WEAKREF,
	)(obj, track_resurrection)
}

vm_il2cpp_gchandle_get_target :: proc (handle: GCHandle) -> Il2CppObject {
	return resolve(
		proc "c" (GCHandle) -> Il2CppObject,
		IL2CPP_GCHANDLE_GET_TARGET,
	)(handle)
}

vm_il2cpp_gchandle_free :: proc (handle: GCHandle) {
	resolve(proc "c" (GCHandle), IL2CPP_GCHANDLE_FREE)(handle)
}

vm_il2cpp_gchandle_foreach_get_target :: proc (
	handle:    GCHandle,
	user_data: rawptr,
	cb:        rawptr,
) {
	resolve(
		proc "c" (GCHandle, rawptr, rawptr),
		IL2CPP_GCHANDLE_FOREACH_GET_TARGET,
	)(handle, user_data, cb)
}

// --- object layout -----------------------------------------------------------

vm_il2cpp_object_header_size :: proc (class: Il2CppClass) -> u32 {
	return resolve(proc "c" (Il2CppClass) -> u32, IL2CPP_OBJECT_HEADER_SIZE)(class)
}

vm_il2cpp_array_object_header_size :: proc () -> uintptr {
	return resolve(proc "c" () -> uintptr, IL2CPP_ARRAY_OBJECT_HEADER_SIZE)()
}

vm_il2cpp_offset_of_array_length_in_array_object_header :: proc () -> uintptr {
	return resolve(
		proc "c" () -> uintptr,
		IL2CPP_OFFSET_OF_ARRAY_LENGTH_IN_ARRAY_OBJECT_HEADER,
	)()
}

vm_il2cpp_offset_of_array_bounds_in_array_object_header :: proc () -> uintptr {
	return resolve(
		proc "c" () -> uintptr,
		IL2CPP_OFFSET_OF_ARRAY_BOUNDS_IN_ARRAY_OBJECT_HEADER,
	)()
}

vm_il2cpp_allocation_granularity :: proc () -> uintptr {
	return resolve(proc "c" () -> uintptr, IL2CPP_ALLOCATION_GRANULARITY)()
}

// --- unity liveness --------------------------------------------------------

vm_il2cpp_unity_liveness_allocate_struct :: proc (
	state: rawptr,
	size:  i32,
	arena: rawptr,
) -> rawptr {
	return resolve(
		proc "c" (rawptr, i32, rawptr) -> rawptr,
		IL2CPP_UNITY_LIVENESS_ALLOCATE_STRUCT,
	)(state, size, arena)
}

vm_il2cpp_unity_liveness_calculation_from_root :: proc (
	state:      rawptr,
	roots:      ^Il2CppObject,
	root_count: i32,
) {
	resolve(
		proc "c" (rawptr, ^Il2CppObject, i32),
		IL2CPP_UNITY_LIVENESS_CALCULATION_FROM_ROOT,
	)(state, roots, root_count)
}

vm_il2cpp_unity_liveness_calculation_from_statics :: proc (state: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_UNITY_LIVENESS_CALCULATION_FROM_STATICS)(state)
}

vm_il2cpp_unity_liveness_finalize :: proc (state: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_UNITY_LIVENESS_FINALIZE)(state)
}

vm_il2cpp_unity_liveness_free_struct :: proc (state: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_UNITY_LIVENESS_FREE_STRUCT)(state)
}

// --- method ----------------------------------------------------------------

vm_il2cpp_method_get_return_type :: proc (method: Il2CppMethod) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppMethod) -> Il2CppType,
		IL2CPP_METHOD_GET_RETURN_TYPE,
	)(method)
}

vm_il2cpp_method_get_declaring_type :: proc (method: Il2CppMethod) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppMethod) -> Il2CppType,
		IL2CPP_METHOD_GET_DECLARING_TYPE,
	)(method)
}

vm_il2cpp_method_get_name :: proc (method: Il2CppMethod) -> cstring {
	return resolve(proc "c" (Il2CppMethod) -> cstring, IL2CPP_METHOD_GET_NAME)(method)
}

vm_il2cpp_method_get_from_reflection :: proc (obj: Il2CppObject) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppObject) -> Il2CppMethod,
		IL2CPP_METHOD_GET_FROM_REFLECTION,
	)(obj)
}

vm_il2cpp_method_get_object :: proc (
	class:    Il2CppClass,
	method:   Il2CppMethod,
	refclass: Il2CppClass,
) -> Il2CppObject {
	return resolve(
		proc "c" (Il2CppClass, Il2CppMethod, Il2CppClass) -> Il2CppObject,
		IL2CPP_METHOD_GET_OBJECT,
	)(class, method, refclass)
}

vm_il2cpp_method_is_generic :: proc (method: Il2CppMethod) -> bool {
	return resolve(proc "c" (Il2CppMethod) -> bool, IL2CPP_METHOD_IS_GENERIC)(method)
}

vm_il2cpp_method_is_inflated :: proc (method: Il2CppMethod) -> bool {
	return resolve(proc "c" (Il2CppMethod) -> bool, IL2CPP_METHOD_IS_INFLATED)(method)
}

vm_il2cpp_method_is_instance :: proc (method: Il2CppMethod) -> bool {
	return resolve(proc "c" (Il2CppMethod) -> bool, IL2CPP_METHOD_IS_INSTANCE)(method)
}

vm_il2cpp_method_get_param_count :: proc (method: Il2CppMethod) -> u32 {
	return resolve(proc "c" (Il2CppMethod) -> u32, IL2CPP_METHOD_GET_PARAM_COUNT)(method)
}

vm_il2cpp_method_get_param :: proc (method: Il2CppMethod, index: u32) -> Il2CppType {
	return resolve(
		proc "c" (Il2CppMethod, u32) -> Il2CppType,
		IL2CPP_METHOD_GET_PARAM,
	)(method, index)
}

vm_il2cpp_method_get_class :: proc (method: Il2CppMethod) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppMethod) -> Il2CppClass,
		IL2CPP_METHOD_GET_CLASS,
	)(method)
}

vm_il2cpp_method_has_attribute :: proc (method: Il2CppMethod, attr: Il2CppClass) -> bool {
	return resolve(
		proc "c" (Il2CppMethod, Il2CppClass) -> bool,
		IL2CPP_METHOD_HAS_ATTRIBUTE,
	)(method, attr)
}

vm_il2cpp_method_get_flags :: proc (method: Il2CppMethod, iflags: ^u32) -> u32 {
	return resolve(
		proc "c" (Il2CppMethod, ^u32) -> u32,
		IL2CPP_METHOD_GET_FLAGS,
	)(method, iflags)
}

vm_il2cpp_method_get_token :: proc (method: Il2CppMethod) -> u32 {
	return resolve(proc "c" (Il2CppMethod) -> u32, IL2CPP_METHOD_GET_TOKEN)(method)
}

vm_il2cpp_method_get_param_name :: proc (method: Il2CppMethod, index: u32) -> cstring {
	return resolve(
		proc "c" (Il2CppMethod, u32) -> cstring,
		IL2CPP_METHOD_GET_PARAM_NAME,
	)(method, index)
}

// --- property ----------------------------------------------------------------

vm_il2cpp_property_get_flags :: proc (prop: Il2CppProperty) -> u32 {
	return resolve(proc "c" (Il2CppProperty) -> u32, IL2CPP_PROPERTY_GET_FLAGS)(prop)
}

vm_il2cpp_property_get_get_method :: proc (prop: Il2CppProperty) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppProperty) -> Il2CppMethod,
		IL2CPP_PROPERTY_GET_GET_METHOD,
	)(prop)
}

vm_il2cpp_property_get_set_method :: proc (prop: Il2CppProperty) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppProperty) -> Il2CppMethod,
		IL2CPP_PROPERTY_GET_SET_METHOD,
	)(prop)
}

vm_il2cpp_property_get_name :: proc (prop: Il2CppProperty) -> cstring {
	return resolve(proc "c" (Il2CppProperty) -> cstring, IL2CPP_PROPERTY_GET_NAME)(prop)
}

vm_il2cpp_property_get_parent :: proc (prop: Il2CppProperty) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppProperty) -> Il2CppClass,
		IL2CPP_PROPERTY_GET_PARENT,
	)(prop)
}

// --- object ----------------------------------------------------------------

vm_il2cpp_object_get_class :: proc (obj: Il2CppObject) -> Il2CppClass {
	return resolve(proc "c" (Il2CppObject) -> Il2CppClass, IL2CPP_OBJECT_GET_CLASS)(obj)
}

vm_il2cpp_object_get_size :: proc (obj: Il2CppObject) -> u32 {
	return resolve(proc "c" (Il2CppObject) -> u32, IL2CPP_OBJECT_GET_SIZE)(obj)
}

vm_il2cpp_object_get_virtual_method :: proc (
	obj:    Il2CppObject,
	method: Il2CppMethod,
	ref:    ^rawptr,
) -> Il2CppMethod {
	return resolve(
		proc "c" (Il2CppObject, Il2CppMethod, ^rawptr) -> Il2CppMethod,
		IL2CPP_OBJECT_GET_VIRTUAL_METHOD,
	)(obj, method, ref)
}

vm_il2cpp_object_new :: proc (class: Il2CppClass) -> Il2CppObject {
	return resolve(proc "c" (Il2CppClass) -> Il2CppObject, IL2CPP_OBJECT_NEW)(class)
}

vm_il2cpp_object_unbox :: proc (obj: Il2CppObject) -> rawptr {
	return resolve(proc "c" (Il2CppObject) -> rawptr, IL2CPP_OBJECT_UNBOX)(obj)
}

vm_il2cpp_value_box :: proc (class: Il2CppClass, data: rawptr) -> Il2CppObject {
	return resolve(
		proc "c" (Il2CppClass, rawptr) -> Il2CppObject,
		IL2CPP_VALUE_BOX,
	)(class, data)
}

// --- monitor ----------------------------------------------------------------

vm_il2cpp_monitor_enter :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), IL2CPP_MONITOR_ENTER)(obj)
}

vm_il2cpp_monitor_try_enter :: proc (obj: Il2CppObject, timeout_ms: u32) -> bool {
	return resolve(
		proc "c" (Il2CppObject, u32) -> bool,
		IL2CPP_MONITOR_TRY_ENTER,
	)(obj, timeout_ms)
}

vm_il2cpp_monitor_exit :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), IL2CPP_MONITOR_EXIT)(obj)
}

vm_il2cpp_monitor_pulse :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), IL2CPP_MONITOR_PULSE)(obj)
}

vm_il2cpp_monitor_pulse_all :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), IL2CPP_MONITOR_PULSE_ALL)(obj)
}

vm_il2cpp_monitor_wait :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), IL2CPP_MONITOR_WAIT)(obj)
}

vm_il2cpp_monitor_try_wait :: proc (obj: Il2CppObject, timeout_ms: u32) -> bool {
	return resolve(
		proc "c" (Il2CppObject, u32) -> bool,
		IL2CPP_MONITOR_TRY_WAIT,
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
		IL2CPP_RUNTIME_INVOKE,
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
		IL2CPP_RUNTIME_INVOKE_CONVERT_ARGS,
	)(method, obj, params, param_count, exc)
}

vm_il2cpp_runtime_class_init :: proc (class: Il2CppClass) {
	resolve(proc "c" (Il2CppClass), IL2CPP_RUNTIME_CLASS_INIT)(class)
}

vm_il2cpp_runtime_object_init :: proc (obj: Il2CppObject) {
	resolve(proc "c" (Il2CppObject), IL2CPP_RUNTIME_OBJECT_INIT)(obj)
}

vm_il2cpp_runtime_object_init_exception :: proc (obj: Il2CppObject, exc: ^Il2CppException) {
	resolve(
		proc "c" (Il2CppObject, ^Il2CppException),
		IL2CPP_RUNTIME_OBJECT_INIT_EXCEPTION,
	)(obj, exc)
}

vm_il2cpp_runtime_unhandled_exception_policy_set :: proc (policy: i32) {
	resolve(proc "c" (i32), IL2CPP_RUNTIME_UNHANDLED_EXCEPTION_POLICY_SET)(policy)
}

// --- string ----------------------------------------------------------------

vm_il2cpp_string_length :: proc (str: Il2CppString) -> i32 {
	return resolve(proc "c" (Il2CppString) -> i32, IL2CPP_STRING_LENGTH)(str)
}

vm_il2cpp_string_chars :: proc (str: Il2CppString) -> ^u16 {
	return resolve(proc "c" (Il2CppString) -> ^u16, IL2CPP_STRING_CHARS)(str)
}

vm_il2cpp_string_new :: proc (str: cstring) -> Il2CppString {
	return resolve(proc "c" (cstring) -> Il2CppString, IL2CPP_STRING_NEW)(str)
}

vm_il2cpp_string_new_len :: proc (str: cstring, length: u32) -> Il2CppString {
	return resolve(
		proc "c" (cstring, u32) -> Il2CppString,
		IL2CPP_STRING_NEW_LEN,
	)(str, length)
}

vm_il2cpp_string_new_utf16 :: proc (text: ^u16, length: i32) -> Il2CppString {
	return resolve(
		proc "c" (^u16, i32) -> Il2CppString,
		IL2CPP_STRING_NEW_UTF16,
	)(text, length)
}

vm_il2cpp_string_new_wrapper :: proc (str: cstring) -> Il2CppString {
	return resolve(proc "c" (cstring) -> Il2CppString, IL2CPP_STRING_NEW_WRAPPER)(str)
}

vm_il2cpp_string_intern :: proc (str: Il2CppString) -> Il2CppString {
	return resolve(proc "c" (Il2CppString) -> Il2CppString, IL2CPP_STRING_INTERN)(str)
}

vm_il2cpp_string_is_interned :: proc (str: Il2CppString) -> bool {
	return resolve(proc "c" (Il2CppString) -> bool, IL2CPP_STRING_IS_INTERNED)(str)
}

// --- thread ----------------------------------------------------------------

vm_il2cpp_thread_current :: proc () -> Il2CppThread {
	return resolve(proc "c" () -> Il2CppThread, IL2CPP_THREAD_CURRENT)()
}

vm_il2cpp_thread_attach :: proc (domain: Il2CppDomain) -> Il2CppThread {
	return resolve(proc "c" (Il2CppDomain) -> Il2CppThread, IL2CPP_THREAD_ATTACH)(domain)
}

vm_il2cpp_thread_detach :: proc (thread: Il2CppThread) {
	resolve(proc "c" (Il2CppThread), IL2CPP_THREAD_DETACH)(thread)
}

vm_il2cpp_is_vm_thread :: proc () -> bool {
	return resolve(proc "c" () -> bool, IL2CPP_IS_VM_THREAD)()
}

vm_il2cpp_current_thread_walk_frame_stack :: proc (cb: rawptr, user_data: rawptr) {
	resolve(
		proc "c" (rawptr, rawptr),
		IL2CPP_CURRENT_THREAD_WALK_FRAME_STACK,
	)(cb, user_data)
}

vm_il2cpp_thread_walk_frame_stack :: proc (
	thread:    Il2CppThread,
	cb:        rawptr,
	user_data: rawptr,
) {
	resolve(
		proc "c" (Il2CppThread, rawptr, rawptr),
		IL2CPP_THREAD_WALK_FRAME_STACK,
	)(thread, cb, user_data)
}

vm_il2cpp_current_thread_get_top_frame :: proc () -> ^Il2CppStackFrameInfo {
	f := resolve(
		proc "c" () -> ^Il2CppStackFrameInfo,
		IL2CPP_CURRENT_THREAD_GET_TOP_FRAME,
	)
	return f()
}

vm_il2cpp_thread_get_top_frame :: proc (thread: Il2CppThread) -> ^Il2CppStackFrameInfo {
	return resolve(
		proc "c" (Il2CppThread) -> ^Il2CppStackFrameInfo,
		IL2CPP_THREAD_GET_TOP_FRAME,
	)(thread)
}

vm_il2cpp_current_thread_get_frame_at :: proc (offset: i32) -> ^Il2CppStackFrameInfo {
	return resolve(
		proc "c" (i32) -> ^Il2CppStackFrameInfo,
		IL2CPP_CURRENT_THREAD_GET_FRAME_AT,
	)(offset)
}

vm_il2cpp_thread_get_frame_at :: proc (
	thread: Il2CppThread,
	offset: i32,
) -> ^Il2CppStackFrameInfo {
	return resolve(
		proc "c" (Il2CppThread, i32) -> ^Il2CppStackFrameInfo,
		IL2CPP_THREAD_GET_FRAME_AT,
	)(thread, offset)
}

vm_il2cpp_current_thread_get_stack_depth :: proc () -> i32 {
	return resolve(proc "c" () -> i32, IL2CPP_CURRENT_THREAD_GET_STACK_DEPTH)()
}

vm_il2cpp_thread_get_stack_depth :: proc (thread: Il2CppThread) -> i32 {
	return resolve(proc "c" (Il2CppThread) -> i32, IL2CPP_THREAD_GET_STACK_DEPTH)(thread)
}

vm_il2cpp_override_stack_backtrace :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_OVERRIDE_STACK_BACKTRACE)(cb)
}

// --- type ----------------------------------------------------------------

vm_il2cpp_type_get_object :: proc (t: Il2CppType) -> Il2CppObject {
	return resolve(proc "c" (Il2CppType) -> Il2CppObject, IL2CPP_TYPE_GET_OBJECT)(t)
}

vm_il2cpp_type_get_type :: proc (t: Il2CppType) -> Cor_Element_Type {
	return resolve(proc "c" (Il2CppType) -> Cor_Element_Type, IL2CPP_TYPE_GET_TYPE)(t)
}

vm_il2cpp_type_get_class_or_element_class :: proc (t: Il2CppType) -> Il2CppClass {
	return resolve(
		proc "c" (Il2CppType) -> Il2CppClass,
		IL2CPP_TYPE_GET_CLASS_OR_ELEMENT_CLASS,
	)(t)
}

vm_il2cpp_type_get_name :: proc (t: Il2CppType) -> cstring {
	return resolve(proc "c" (Il2CppType) -> cstring, IL2CPP_TYPE_GET_NAME)(t)
}

vm_il2cpp_type_get_name_chunked :: proc (
	t:            Il2CppType,
	chunk_report: proc "c" (chunk, user_data: rawptr),
	user_data:    rawptr,
) {
	resolve(
		proc "c" (Il2CppType, proc "c" (rawptr, rawptr), rawptr),
		IL2CPP_TYPE_GET_NAME_CHUNKED,
	)(t, chunk_report, user_data)
}

vm_il2cpp_type_is_byref :: proc (t: Il2CppType) -> bool {
	return resolve(proc "c" (Il2CppType) -> bool, IL2CPP_TYPE_IS_BYREF)(t)
}

vm_il2cpp_type_get_attrs :: proc (t: Il2CppType) -> u32 {
	return resolve(proc "c" (Il2CppType) -> u32, IL2CPP_TYPE_GET_ATTRS)(t)
}

vm_il2cpp_type_equals :: proc (a: Il2CppType, b: Il2CppType) -> bool {
	return resolve(proc "c" (Il2CppType, Il2CppType) -> bool, IL2CPP_TYPE_EQUALS)(a, b)
}

vm_il2cpp_type_get_assembly_qualified_name :: proc (t: Il2CppType) -> cstring {
	return resolve(
		proc "c" (Il2CppType) -> cstring,
		IL2CPP_TYPE_GET_ASSEMBLY_QUALIFIED_NAME,
	)(t)
}

vm_il2cpp_type_get_reflection_name :: proc (t: Il2CppType) -> cstring {
	return resolve(proc "c" (Il2CppType) -> cstring, IL2CPP_TYPE_GET_REFLECTION_NAME)(t)
}

vm_il2cpp_type_is_static :: proc (t: Il2CppType) -> bool {
	return resolve(proc "c" (Il2CppType) -> bool, IL2CPP_TYPE_IS_STATIC)(t)
}

vm_il2cpp_type_is_pointer_type :: proc (t: Il2CppType) -> bool {
	return resolve(proc "c" (Il2CppType) -> bool, IL2CPP_TYPE_IS_POINTER_TYPE)(t)
}

// --- misc (memory snapshot, callbacks, debugger, custom attrs) ---------------

vm_il2cpp_capture_memory_snapshot :: proc (snapshot: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_CAPTURE_MEMORY_SNAPSHOT)(snapshot)
}

vm_il2cpp_free_captured_memory_snapshot :: proc (snapshot: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_FREE_CAPTURED_MEMORY_SNAPSHOT)(snapshot)
}

vm_il2cpp_set_find_plugin_callback :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_SET_FIND_PLUGIN_CALLBACK)(cb)
}

vm_il2cpp_register_log_callback :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_REGISTER_LOG_CALLBACK)(cb)
}

vm_il2cpp_debugger_set_agent_options :: proc (options: cstring) {
	resolve(proc "c" (cstring), IL2CPP_DEBUGGER_SET_AGENT_OPTIONS)(options)
}

vm_il2cpp_is_debugger_attached :: proc () -> bool {
	return resolve(proc "c" () -> bool, IL2CPP_IS_DEBUGGER_ATTACHED)()
}

vm_il2cpp_register_debugger_agent_transport :: proc (transport: rawptr, timeout: i64) {
	resolve(
		proc "c" (rawptr, i64),
		IL2CPP_REGISTER_DEBUGGER_AGENT_TRANSPORT,
	)(transport, timeout)
}

vm_il2cpp_debug_foreach_method :: proc (visit: rawptr, user_data: rawptr) {
	resolve(proc "c" (rawptr, rawptr), IL2CPP_DEBUG_FOREACH_METHOD)(visit, user_data)
}

vm_il2cpp_debug_get_method_info :: proc (method: Il2CppMethod) -> rawptr {
	return resolve(
		proc "c" (Il2CppMethod) -> rawptr,
		IL2CPP_DEBUG_GET_METHOD_INFO,
	)(method)
}

vm_il2cpp_unity_install_unitytls_interface :: proc (iface: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_UNITY_INSTALL_UNITYTLS_INTERFACE)(iface)
}

vm_il2cpp_custom_attrs_from_class :: proc (class: Il2CppClass) -> rawptr {
	return resolve(
		proc "c" (Il2CppClass) -> rawptr,
		IL2CPP_CUSTOM_ATTRS_FROM_CLASS,
	)(class)
}

vm_il2cpp_custom_attrs_from_method :: proc (method: Il2CppMethod) -> rawptr {
	return resolve(
		proc "c" (Il2CppMethod) -> rawptr,
		IL2CPP_CUSTOM_ATTRS_FROM_METHOD,
	)(method)
}

vm_il2cpp_custom_attrs_from_field :: proc (
	class: Il2CppClass,
	field: Il2CppField,
) -> rawptr {
	return resolve(
		proc "c" (Il2CppClass, Il2CppField) -> rawptr,
		IL2CPP_CUSTOM_ATTRS_FROM_FIELD,
	)(class, field)
}

vm_il2cpp_custom_attrs_get_attr :: proc (attrs: rawptr, attr_class: Il2CppClass) -> rawptr {
	return resolve(
		proc "c" (rawptr, Il2CppClass) -> rawptr,
		IL2CPP_CUSTOM_ATTRS_GET_ATTR,
	)(attrs, attr_class)
}

vm_il2cpp_custom_attrs_has_attr :: proc (attrs: rawptr, attr_class: Il2CppClass) -> bool {
	return resolve(
		proc "c" (rawptr, Il2CppClass) -> bool,
		IL2CPP_CUSTOM_ATTRS_HAS_ATTR,
	)(attrs, attr_class)
}

vm_il2cpp_custom_attrs_construct :: proc (attrs: rawptr) -> Il2CppObject {
	return resolve(
		proc "c" (rawptr) -> Il2CppObject,
		IL2CPP_CUSTOM_ATTRS_CONSTRUCT,
	)(attrs)
}

vm_il2cpp_custom_attrs_free :: proc (attrs: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_CUSTOM_ATTRS_FREE)(attrs)
}

vm_il2cpp_class_set_userdata :: proc (class: Il2CppClass, userdata: rawptr) {
	resolve(proc "c" (Il2CppClass, rawptr), IL2CPP_CLASS_SET_USERDATA)(class, userdata)
}

vm_il2cpp_class_get_userdata_offset :: proc () -> i32 {
	return resolve(proc "c" () -> i32, IL2CPP_CLASS_GET_USERDATA_OFFSET)()
}

vm_il2cpp_set_default_thread_affinity :: proc (mask: i64) {
	resolve(proc "c" (i64), IL2CPP_SET_DEFAULT_THREAD_AFFINITY)(mask)
}

vm_il2cpp_unity_set_android_network_up_state_func :: proc (cb: rawptr) {
	resolve(proc "c" (rawptr), IL2CPP_UNITY_SET_ANDROID_NETWORK_UP_STATE_FUNC)(cb)
}
