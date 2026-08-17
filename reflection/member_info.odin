package reflection

import "../il2cpp"

Member_Kind :: enum {
	Field,
	Method,
	Property,
}

Member_Info :: struct {
	kind:     Member_Kind,
	field:    Field_Info,
	method:   Method_Info,
	property: Property_Info,
}

member_name :: proc (m: Member_Info) -> string {
	switch m.kind {
	case .Field:
		return field_name(m.field)
	case .Method:
		return method_name(m.method)
	case .Property:
		return property_name(m.property)
	}
	return ""
}

member_declaring_class :: proc (m: Member_Info) -> il2cpp.Il2CppClass {
	switch m.kind {
	case .Field:
		return field_declaring_class(m.field)
	case .Method:
		return method_declaring_class(m.method)
	case .Property:
		return property_declaring_class(m.property)
	}
	return 0
}

member_is_static :: proc (m: Member_Info) -> bool {
	switch m.kind {
	case .Field:
		return field_is_static(m.field)
	case .Method:
		return method_is_static(m.method)
	case .Property:
		return property_is_static(m.property)
	}
	return false
}

// only methods expose a token via the api. fields/properties return 0.
member_metadata_token :: proc (m: Member_Info) -> u32 {
	if m.kind == .Method {
		return il2cpp.vm_il2cpp_method_get_token(il2cpp.Il2CppMethod(m.method))
	}
	return 0
}

// enumerates every field/method/property of class as Member_Infos
// order: field, method, property.
// caller must delete the returned slice
class_members :: proc (class: il2cpp.Il2CppClass, allocator := context.allocator) -> []Member_Info {
	ms := make([dynamic]Member_Info, allocator)

	iter: rawptr
	for {
		f := il2cpp.vm_il2cpp_class_get_fields(class, &iter)
		if f == 0 {
			break
		}
		append(&ms, Member_Info {
			kind  = .Field,
			field = Field_Info(f),
		})
	}
	iter = nil
	for {
		m := il2cpp.vm_il2cpp_class_get_methods(class, &iter)
		if m == 0 {
			break
		}
		append(&ms, Member_Info {
			kind   = .Method,
			method = Method_Info(m),
		})
	}
	iter = nil
	for {
		p := il2cpp.vm_il2cpp_class_get_properties(class, &iter)
		if p == 0 {
			break
		}
		append(&ms, Member_Info {
			kind     = .Property,
			property = Property_Info(p),
		})
	}
	return ms[:]
}
