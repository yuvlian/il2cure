package extra

import "core:strings"
import "../il2cpp"
import "../reflection"

// "Namespace.Type" (or just "Type" when global)
// caller must delete the returned string
class_full_name :: proc (class: il2cpp.Il2CppClass, allocator := context.allocator) -> string {
	ns := il2cpp.class_namespace(class)
	name := il2cpp.class_name(class)
	if ns == "" {
		return strings.clone(name, allocator)
	}
	return strings.concatenate({ns, ".", name}, allocator)
}

// renders the type's C#-ish name, optionally namespace-prefixed
type_format_name :: proc (t: il2cpp.Il2CppType, with_namespace: bool) -> string {
	name := reflection.type_il_name(t)
	if !with_namespace {
		return name
	}
	c := il2cpp.type_class(t)
	if c == 0 {
		return name
	}
	b := strings.builder_make(context.temp_allocator)
	ns := il2cpp.class_namespace(c)
	if ns != "" {
		strings.write_string(&b, ns)
		strings.write_byte(&b, '.')
	}
	strings.write_string(&b, name)
	return strings.to_string(b)
}

// renders the access modifier for a Field_Attributes value
// ("public"/"private"/"protected"/"internal"/"protected internal"/"")
field_access :: proc (attrs: reflection.Field_Attributes) -> string {
	switch attrs & reflection.Field_Attributes_FieldAccessMask {
	case reflection.Field_Attributes_Private:
		return "private"
	case reflection.Field_Attributes_Public:
		return "public"
	case reflection.Field_Attributes_Family:
		return "protected"
	case reflection.Field_Attributes_Assembly, reflection.Field_Attributes_FamANDAssem:
		return "internal"
	case reflection.Field_Attributes_FamORAssem:
		return "protected internal"
	}
	return ""
}

// renders "modifier " (access + const/static/readonly) for a field
field_modifier :: proc (attrs: reflection.Field_Attributes) -> string {
	b := strings.builder_make(context.temp_allocator)
	strings.write_string(&b, field_access(attrs))
	if strings.builder_len(b) > 0 {
		strings.write_byte(&b, ' ')
	}
	if attrs & reflection.Field_Attributes_Literal == reflection.Field_Attributes_Literal {
		strings.write_string(&b, "const ")
	} else {
		if attrs & reflection.Field_Attributes_Static == reflection.Field_Attributes_Static {
			strings.write_string(&b, "static ")
		}
		if attrs & reflection.Field_Attributes_InitOnly == reflection.Field_Attributes_InitOnly {
			strings.write_string(&b, "readonly ")
		}
	}
	return strings.to_string(b)
}

// renders the access modifier for a Method_Attributes value
method_access :: proc (attrs: reflection.Method_Attributes) -> string {
	switch attrs & reflection.Method_Attributes_MemberAccessMask {
	case reflection.Method_Attributes_Private:
		return "private"
	case reflection.Method_Attributes_Public:
		return "public"
	case reflection.Method_Attributes_Family:
		return "protected"
	case reflection.Method_Attributes_Assembly, reflection.Method_Attributes_FamANDAssem:
		return "internal"
	case reflection.Method_Attributes_FamORAssem:
		return "protected internal"
	}
	return ""
}

// renders the full modifier prefix for a method
// ("public static virtual " etc.)
method_modifier :: proc (attrs: reflection.Method_Attributes) -> string {
	b := strings.builder_make(context.temp_allocator)
	write_word(&b, method_access(attrs))
	if attrs & reflection.Method_Attributes_Abstract == reflection.Method_Attributes_Abstract {
		write_word(&b, "abstract")
	} else {
		if attrs & reflection.Method_Attributes_Static == reflection.Method_Attributes_Static {
			write_word(&b, "static")
		}
		if attrs & reflection.Method_Attributes_NewSlot == reflection.Method_Attributes_NewSlot {
			write_word(&b, "virtual")
		} else if attrs & reflection.Method_Attributes_Virtual == reflection.Method_Attributes_Virtual {
			write_word(&b, "override")
		}
	}
	return strings.to_string(b)
}

// renders the visibility keyword for a Type_Attributes value
type_visibility :: proc (attrs: reflection.Type_Attributes) -> string {
	switch attrs & reflection.Type_Attributes_VisibilityMask {
	case reflection.Type_Attributes_Public:
		return "public"
	case reflection.Type_Attributes_NestedPublic:
		return "public"
	case reflection.Type_Attributes_NestedPrivate:
		return "private"
	case reflection.Type_Attributes_NestedFamily:
		return "protected"
	case reflection.Type_Attributes_NestedAssembly, reflection.Type_Attributes_NestedFamANDAssem:
		return "internal"
	case reflection.Type_Attributes_NestedFamORAssem:
		return "protected internal"
	}
	return ""
}

// renders the "public static readonly " prefix for a field
field_modifier_str :: proc (f: reflection.Field_Info) -> string {
	return field_modifier(reflection.field_attributes(f))
}

// renders the "public static virtual " prefix for a method
method_modifier_str :: proc (m: reflection.Method_Info) -> string {
	return method_modifier(reflection.method_attributes(m))
}

// renders the param's "<modifier><type> <name>"
parameter_format_csharp :: proc (p: reflection.Parameter_Info, type_name: string) -> string {
	b := strings.builder_make(context.temp_allocator)
	if reflection.parameter_is_out(p) {
		strings.write_string(&b, "out ")
	} else if reflection.parameter_is_byref(p) {
		strings.write_string(&b, "ref ")
	}
	strings.write_string(&b, type_name)
	name := reflection.parameter_name(p)
	if name != "" {
		strings.write_byte(&b, ' ')
		strings.write_string(&b, name)
	}
	return strings.to_string(b)
}

// appends word (a modifier token) to b followed by a space, unless empty
write_word :: proc (b: ^strings.Builder, word: string) {
	if word == "" {
		return
	}
	strings.write_string(b, word)
	strings.write_byte(b, ' ')
}

// renders a " (generic)"/" (inflated)" suffix for a class
class_kind_suffix :: proc (class: il2cpp.Il2CppClass) -> string {
	switch {
	case il2cpp.vm_il2cpp_class_is_generic(class):
		return " (generic)"
	case il2cpp.vm_il2cpp_class_is_inflated(class):
		return " (inflated)"
	}
	return ""
}

// renders a " (generic)"/" (inflated)" suffix for a method
method_kind_suffix :: proc (method: il2cpp.Il2CppMethod) -> string {
	switch {
	case il2cpp.vm_il2cpp_method_is_generic(method):
		return " (generic)"
	case il2cpp.vm_il2cpp_method_is_inflated(method):
		return " (inflated)"
	}
	return ""
}

// renders "("type, type")" from a method's declared params (by the raw
// type name only)
// caller must delete the returned string
method_param_list :: proc (
	method:      il2cpp.Il2CppMethod,
	count:       u32,
	allocator := context.allocator,
) -> string {
	b := strings.builder_make(allocator)
	strings.write_byte(&b, '(')
	for i: u32 = 0; i < count; i += 1 {
		if i > 0 {
			strings.write_string(&b, ", ")
		}
		t := il2cpp.vm_il2cpp_method_get_param(method, i)
		strings.write_string(&b, string(il2cpp.vm_il2cpp_type_get_name(t)))
	}
	strings.write_byte(&b, ')')
	return strings.to_string(b)
}

// renders "p0: T0, p1: T1…" (C# named params) from a method's Parameter_Infos,
// reusing parameter_format_csharp per param
param_list_csharp :: proc (m: reflection.Method_Info) -> string {
	b := strings.builder_make(context.temp_allocator)
	params := reflection.method_parameters(m)
	for p, i in params {
		if i > 0 {
			strings.write_string(&b, ", ")
		}
		t := type_format_name(reflection.parameter_type(p), true)
		strings.write_string(&b, parameter_format_csharp(p, t))
	}
	return strings.to_string(b)
}
