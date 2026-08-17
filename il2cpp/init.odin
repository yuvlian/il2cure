package il2cpp

import "core:strings"

Table :: struct {
	classes:    map[string]Il2CppClass,   // "Namespace.Type"
	methods:    map[string]Il2CppMethod,  // "Namespace.Type::MethodName"
	assemblies: [dynamic]Il2CppAssembly,
}

@(private)
state: ^Table

is_initialized :: proc () -> bool {
	return state != nil
}

// enumerates the il2cpp domain and builds the class/method tables.
// returns false if the domain is unreachable (GameAssembly not loaded yet,
// or domain_get failed)
init :: proc (resolver := default_export_resolver) -> bool {
	if state != nil {
		return true
	}

	// install the strategy before the first binding resolves
	active_resolver = resolver

	domain := vm_il2cpp_domain_get()
	if domain == 0 {
		return false
	}

	vm_il2cpp_thread_attach(domain)

	table := new(Table)

	count: uintptr
	asms := vm_il2cpp_domain_get_assemblies(domain, &count)

	table.assemblies = make([dynamic]Il2CppAssembly, 0, count)
	for i: uintptr = 0; i < count; i += 1 {
		asm_item := asms[i]
		append(&table.assemblies, asm_item)

		image := vm_il2cpp_assembly_get_image(asm_item)
		if image == 0 {
			continue
		}

		n := vm_il2cpp_image_get_class_count(image)
		for c: uintptr = 0; c < n; c += 1 {
			class := vm_il2cpp_image_get_class(image, c)
			if class == 0 {
				continue
			}

			cname := string(vm_il2cpp_class_get_name(class))
			cns := string(vm_il2cpp_class_get_namespace(class))
			full_name := build_full_name(cns, cname)

			if _, ok := table.classes[full_name]; !ok {
				table.classes[full_name] = class
			}

			iter: rawptr
			for {
				method := vm_il2cpp_class_get_methods(class, &iter)
				if method == 0 {
					break
				}
				mname := string(vm_il2cpp_method_get_name(method))
				method_key := strings.concatenate({full_name, "::", mname})
				if _, ok := table.methods[method_key]; !ok {
					table.methods[method_key] = method
				}
				delete(method_key)
			}

			delete(full_name)
		}
	}

	state = table
	return true
}

// "Namespace.Type"
build_full_name :: proc (ns, name: string, allocator := context.allocator) -> string {
	if ns == "" {
		return strings.clone(name, allocator)
	}
	return strings.concatenate({ns, ".", name}, allocator)
}

// looks up a class by full name ("Namespace.Type").
// on a map miss it falls back to the lazy runtime scan (find_class_lazy)
find_class :: proc (full_name: string) -> (Il2CppClass, bool) {
	if state != nil {
		if class, ok := state.classes[full_name]; ok {
			return class, true
		}
	}
	ns, name, _ := split_full_name(full_name)
	if class, ok := find_class_lazy(ns, name); ok {
		if state != nil {
			state.classes[full_name] = class
		}
		return class, true
	}
	return {}, false
}

// looks up a method by "Namespace.Type::MethodName".
//
// if the name overloads and arg_count >= 0
// the class's method list is scanned
// for the first method with that parameter count
//
// if the prebuilt table misses, it falls back to lazy runtime resolution
// (class name-scan + get_method_from_name)
find_method :: proc (full_name: string, arg_count: i32 = -1) -> (Il2CppMethod, bool) {
	if state == nil {
		return {}, false
	}
	method, ok := state.methods[full_name]
	if !ok {
		ns, cls, name := split_full_name(full_name)
		k, kok := find_class_lazy(ns, cls)
		if !kok {
			return {}, false
		}
		m, mok := class_method(k, name, arg_count)
		if !mok {
			return {}, false
		}
		state.methods[full_name] = m
		return m, true
	}
	if arg_count >= 0 {
		class := vm_il2cpp_method_get_class(method)
		if class == 0 {
			return method, true
		}
		want_name := method_name_of(full_name)
		iter: rawptr
		for {
			candidate := vm_il2cpp_class_get_methods(class, &iter)
			if candidate == 0 {
				break
			}
			if string(vm_il2cpp_method_get_name(candidate)) == want_name &&
			   i32(vm_il2cpp_method_get_param_count(candidate)) == arg_count {
				return candidate, true
			}
		}
	}
	return method, true
}

// resolves a class by (namespace, name) at call time,
// walking domain assemblies -> images -> classes and matching by
// class_get_name / class_get_namespace
//
// maybe use il2cpp_class_from_name instead?
find_class_lazy :: proc (namespace: string, name: string) -> (Il2CppClass, bool) {
	domain := vm_il2cpp_domain_get()
	if domain == 0 {
		return {}, false
	}
	count: uintptr
	asms := vm_il2cpp_domain_get_assemblies(domain, &count)
	for i: uintptr = 0; i < count; i += 1 {
		image := vm_il2cpp_assembly_get_image(asms[i])
		if image == 0 {
			continue
		}
		n := vm_il2cpp_image_get_class_count(image)
		for c: uintptr = 0; c < n; c += 1 {
			class := vm_il2cpp_image_get_class(image, c)
			if class == 0 {
				continue
			}
			if string(vm_il2cpp_class_get_name(class)) != name {
				continue
			}
			if namespace != "" &&
				string(vm_il2cpp_class_get_namespace(class)) != namespace {
				continue
			}
			return class, true
		}
	}
	return {}, false
}

// "Namespace.Type::MethodName" -> (namespace, type, method)
@(private)
split_full_name :: proc (full_name: string) -> (ns, cls, name: string) {
	rest := full_name
	if mi := strings.last_index(rest, "::"); mi >= 0 {
		name = rest[mi + 2:]
		rest = rest[:mi]
	} else {
		name = rest
	}
	if di := strings.last_index(rest, "."); di < 0 {
		ns, cls = "", rest
	} else {
		ns, cls = rest[:di], rest[di + 1:]
	}
	return
}

// just for startup logging lol,
// the lazy fallback above works independently of these
map_stats :: proc () -> (classes, methods: int) {
	if state == nil {
		return 0, 0
	}
	return len(state.classes), len(state.methods)
}

// resolves a method directly from an already-held class via
// il2cpp_class_get_method_from_name.
// cheaper than the global table walk and does not require init.
// arg_count disambiguates overloads; -1 takes any
class_method :: proc (
	class:     Il2CppClass,
	name:      string,
	arg_count: i32 = -1,
) -> (Il2CppMethod, bool) {
	if class == 0 {
		return {}, false
	}
	if arg_count >= 0 {
		m := vm_il2cpp_class_get_method_from_name(class,
			cstring(raw_data(name)), arg_count)
		return m, m != 0
	}
	return class_method_any(class, name)
}

// takes the first method found
@(private)
class_method_any :: proc (class: Il2CppClass, name: string) -> (Il2CppMethod, bool) {
	iter: rawptr
	for {
		m := vm_il2cpp_class_get_methods(class, &iter)
		if m == 0 {
			break
		}
		if string(vm_il2cpp_method_get_name(m)) == name {
			return m, true
		}
	}
	return {}, false
}

// method_name_of returns the segment after the last "::"
// (or the whole string if none)
method_name_of :: proc (full_name: string) -> string {
	idx := strings.last_index(full_name, "::")
	if idx < 0 {
		return full_name
	}
	return full_name[idx + 2:]
}

shutdown :: proc () {
	if state == nil {
		return
	}
	delete(state.classes)
	delete(state.methods)
	delete(state.assemblies)
	free(state)
	state = nil
}
