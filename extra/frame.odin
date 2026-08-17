package extra

import "core:mem"
import "core:reflect"
import "core:strings"
import "../il2cpp"

Frame_Field :: struct {
	name:   string,  // managed (C#) field name this member resolved to
	offset: uintptr, // raw byte offset of the field in the managed object
	ok:     bool,    // false when the class has no matching field (member stays zero)
}

// carries the per-member bindings for a (class, T) pair,
// fields is parallel to T's struct members (by order of declaration)
Frame :: struct {
	class:     il2cpp.Il2CppClass,
	fields:    []Frame_Field,
	allocator: mem.Allocator,
}

// binds T's members to `class` fields by name
frame_of :: proc (
	class:       il2cpp.Il2CppClass,
	$T:          typeid,
	allocator := context.allocator,
) -> (Frame, bool) {
	if class == 0 {
		return {}, false
	}
	names := reflect.struct_field_names(T)
	frame := Frame {
		class     = class,
		allocator = allocator,
	}
	frame.fields = make([]Frame_Field, len(names), allocator)
	for name, i in names {
		field, managed_name, ok := frame_resolve_field(class,
			name, reflect.struct_field_tags(T)[i])
		offset: uintptr
		if ok {
			offset = il2cpp.field_offset(field)
		}
		frame.fields[i] = Frame_Field {
			name   = managed_name,
			offset = offset,
			ok     = ok,
		}
	}
	return frame, true
}

// looks up one Odin member's managed field,
// trying a `frame:"X"` tag with different cases
frame_resolve_field :: proc (
	class: il2cpp.Il2CppClass,
	name:  string,
	tag:   reflect.Struct_Tag,
) -> (field: il2cpp.Il2CppField, managed_name: string, ok: bool) {
	candidates := frame_field_candidates(name, tag)
	for cand, i in candidates {
		if cand == "" || frame_candidates_contain(candidates, i, cand) {
			continue
		}
		if f, found := il2cpp.field_of(class, cand); found {
			return f, cand, true
		}
	}
	return {}, "", false
}

// lists the managed names to try for an Odin member.
// Order: `frame` tag, verbatim, PascalCase, camelCase.
frame_field_candidates :: proc (name: string, tag: reflect.Struct_Tag) -> [4]string {
	tagged := frame_tag_name(tag)
	pascal, _ := strings.to_pascal_case(name, context.temp_allocator)
	camel, _ := strings.to_camel_case(name, context.temp_allocator)
	return [4]string {
		tagged,
		name,
		(pascal if pascal != name else ""),
		(camel if camel != name else ""),
	}
}

frame_tag_name :: proc (tag: reflect.Struct_Tag) -> string {
	s := string(tag)
	idx := strings.index(s, "frame:")
	if idx < 0 {
		return ""
	}
	value := strings.trim(s[idx + len("frame:"):], " \t\"")
	end := 0
	for end < len(value) {
		c := value[end]
		if c == ' ' || c == '\t' || c == '"' || c == ',' {
			break
		}
		end += 1
	}
	return value[:end]
}

frame_candidates_contain :: proc (cands: [4]string, n: int, s: string) -> bool {
	for i in 0 ..< n {
		if cands[i] == s {
			return true
		}
	}
	return false
}

// copies every matched managed field of obj into a T value by raw offset
frame_read :: proc (frame: Frame, obj: il2cpp.Il2CppObject, $T: typeid) -> (T, bool) {
	if obj == 0 {
		return {}, false
	}
	offsets := reflect.struct_field_offsets(T)
	out: T
	for f, i in frame.fields {
		if !f.ok {
			continue
		}
		ext := frame_field_extent(offsets, i, size_of(T))
		dst := rawptr(uintptr(&out) + offsets[i])
		src := rawptr(uintptr(obj) + f.offset)
		mem.copy(dst, src, int(ext))
	}
	return out, true
}

// copies a T value's value-type members into the managed object
// by raw offset. Not for reference-typed members.
frame_write :: proc (frame: Frame, obj: il2cpp.Il2CppObject, value: $T) {
	if obj == 0 {
		return
	}
	v := value
	offsets := reflect.struct_field_offsets(T)
	for f, i in frame.fields {
		if !f.ok {
			continue
		}
		ext := frame_field_extent(offsets, i, size_of(T))
		src := rawptr(uintptr(&v) + offsets[i])
		dst := rawptr(uintptr(obj) + f.offset)
		mem.copy(dst, src, int(ext))
	}
}

// returns the byte span a member occupies in the struct:
// offset to the next member (or to the struct end for the last).
frame_field_extent :: proc (offsets: []uintptr, i: int, total: int) -> uintptr {
	if i + 1 < len(offsets) {
		return offsets[i + 1] - offsets[i]
	}
	return uintptr(total) - offsets[i]
}

frame_destroy :: proc (frame: ^Frame) {
	delete(frame.fields, frame.allocator)
	frame.fields = nil
	frame.class = 0
}
