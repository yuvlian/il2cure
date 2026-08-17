package il2cpp

// raw-layout accessors for managed collections (List<T>, Dictionary<K,V>)
// they share the 3-pointer header of every Il2CppObject

LIST_ITEMS_OFFSET   :: 16  // ^Il2CppArray backing store
LIST_SIZE_OFFSET    :: 24  // i32 logical length
LIST_VERSION_OFFSET :: 28  // i32 version (bump on structural change), unused

DICT_BUCKETS_OFFSET :: 16  // ^Il2CppArray of buckets, unused
DICT_ENTRIES_OFFSET :: 24  // ^Il2CppArray of {hash,key,value} entries
DICT_COUNT_OFFSET   :: 32  // i32 entry count

list_items :: proc (list: Il2CppObject) -> Il2CppArray {
	return Il2CppArray((^uintptr)(uintptr(list) + LIST_ITEMS_OFFSET)^)
}

list_size :: proc (list: Il2CppObject) -> i32 {
	return (^i32)(uintptr(list) + LIST_SIZE_OFFSET)^
}

list_capacity :: proc (list: Il2CppObject) -> uintptr {
	return array_length(list_items(list))
}

// returns the i-th element (T)
list_get :: proc (list: Il2CppObject, index: uintptr, $T: typeid) -> T {
	return array_get(list_items(list), index, T)
}

// returns a slice view over the logical (size) elements
list_iter :: proc (list: Il2CppObject, $T: typeid) -> []T {
	items := list_items(list)
	size := uintptr(list_size(list))
	return ([]T)(array_elements(items, T))[:size]
}

Entry :: struct ($K: typeid, $V: typeid) #packed {
	hash:  i32,
	next:  i32,
	key:   K,
	value: V,
}

dict_entries :: proc (dict: Il2CppObject) -> Il2CppArray {
	return Il2CppArray((^uintptr)(uintptr(dict) + DICT_ENTRIES_OFFSET)^)
}

dict_count :: proc (dict: Il2CppObject) -> i32 {
	return (^i32)(uintptr(dict) + DICT_COUNT_OFFSET)^
}

// maps the i-th entries slot to its (key, value).
// caller decides how to walk buckets/count.
dict_entry :: proc (
	dict:  Il2CppObject,
	index: uintptr,
	$K:    typeid,
	$V:    typeid,
) -> (K, V, bool) {
	entries := dict_entries(dict)
	if index >= array_length(entries) {
		return {}, {}, false
	}
	entry := Entry(K, V)
	addr := uintptr(entries) + ARRAY_ELEMENTS_OFFSET + index * size_of(entry)
	return (^K)(addr + 8)^, (^V)(addr + 8 + size_of(K))^, true
}
