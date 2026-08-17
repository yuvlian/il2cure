package unity

import "core:strings"

import "../il2cpp"
import "../reflection"

GameObject :: distinct il2cpp.Il2CppObject

game_object_find :: proc (name_value: string) -> (GameObject, bool) {
	arg := il2cpp.string_new(name_value)
	m, ok := il2cpp.find_method("UnityEngine.GameObject::Find")
	if !ok {
		return GameObject(0), false
	}
	fn := il2cpp.method_proc(m, proc "c" (
		il2cpp.Il2CppObject,
		il2cpp.Il2CppString,
		il2cpp.Il2CppMethod,
	) -> il2cpp.Il2CppObject)
	if fn == nil {
		return GameObject(0), false
	}
	res := fn(il2cpp.Il2CppObject(0), arg, m)
	return GameObject(res), res != 0
}

game_object_create :: proc (name_value: string) -> (GameObject, bool) {
	arg := il2cpp.string_new(name_value)
	res, ok := invoke_named(
		0,
		"UnityEngine.GameObject",
		".ctor",
		[]string {"System.String"},
		[]uintptr {uintptr(&arg)},
	)
	return GameObject(res), ok
}

game_object_get_transform :: proc (go: GameObject) -> (Transform, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"get_transform",
	)
	return Transform(res), ok && res != 0
}

game_object_get_component :: proc (go: GameObject, type_name: string) -> (Component, bool) {
	arg := il2cpp.string_new(type_name)
	m, ok := il2cpp.find_method("UnityEngine.GameObject::GetComponent")
	if !ok {
		return Component(0), false
	}
	fn := il2cpp.method_proc(m, proc "c" (
		il2cpp.Il2CppObject,
		il2cpp.Il2CppString,
		il2cpp.Il2CppMethod,
	) -> il2cpp.Il2CppObject)
	if fn == nil {
		return Component(0), false
	}
	res := fn(il2cpp.Il2CppObject(go), arg, m)
	return Component(res), res != 0
}

game_object_active_self :: proc (go: GameObject) -> (bool, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"get_activeSelf",
	)
	if !ok {
		return false, false
	}
	return unbox_bool(res), true
}

game_object_active_in_hierarchy :: proc (go: GameObject) -> (bool, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"get_activeInHierarchy",
	)
	if !ok {
		return false, false
	}
	return unbox_bool(res), true
}

game_object_get_name :: proc (go: GameObject) -> (il2cpp.Il2CppString, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"get_name",
	)
	return il2cpp.Il2CppString(res), ok && res != 0
}

game_object_get_layer :: proc (go: GameObject) -> (i32, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"get_layer",
	)
	if !ok {
		return 0, false
	}
	return read_value(res, i32)
}

game_object_set_layer :: proc (go: GameObject, layer: i32) -> bool {
	l := layer
	_, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"set_layer",
		[]string {"System.Int32"},
		[]uintptr {uintptr(&l)},
	)
	return ok
}

game_object_ctor :: proc (go: GameObject, name: il2cpp.Il2CppString) -> bool {
	nm := name
	_, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		".ctor",
		[]string {"System.String"},
		[]uintptr {uintptr(&nm)},
	)
	return ok
}

game_object_get_components :: proc (go: GameObject, t: reflection.Runtime_Type) -> (il2cpp.Il2CppArray, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"GetComponents",
		[]string {"System.Type"},
		[]uintptr {uintptr(t)},
	)
	return il2cpp.Il2CppArray(res), ok && res != 0
}

game_object_get_component_type :: proc (go: GameObject, t: reflection.Runtime_Type) -> (Component, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"GetComponent",
		[]string {"System.Type"},
		[]uintptr {uintptr(t)},
	)
	return Component(res), ok && res != 0
}

game_object_get_component_in_children :: proc (go: GameObject, t: reflection.Runtime_Type) -> (Component, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"GetComponentInChildren",
		[]string {"System.Type"},
		[]uintptr {uintptr(t)},
	)
	return Component(res), ok && res != 0
}

game_object_get_components_in_children :: proc (
	go:               GameObject,
	t:                reflection.Runtime_Type,
	include_inactive: bool,
) -> (il2cpp.Il2CppArray, bool) {
	inc := include_inactive
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"GetComponentsInChildren",
		[]string {"System.Type", "System.Boolean"},
		[]uintptr {uintptr(t), uintptr(&inc)},
	)
	return il2cpp.Il2CppArray(res), ok && res != 0
}

game_object_set_active :: proc (go: GameObject, active: bool) -> bool {
	a := active
	_, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"SetActive",
		[]string {"System.Boolean"},
		[]uintptr {uintptr(&a)},
	)
	return ok
}

game_object_add_component :: proc (go: GameObject, t: reflection.Runtime_Type) -> (Component, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"AddComponent",
		[]string {"System.Type"},
		[]uintptr {uintptr(t)},
	)
	return Component(res), ok && res != 0
}

game_object_set_name :: proc (go: GameObject, value: il2cpp.Il2CppString) -> bool {
	v := value
	_, ok := invoke_named(
		il2cpp.Il2CppObject(go),
		"UnityEngine.GameObject",
		"set_name",
		[]string {"System.String"},
		[]uintptr {uintptr(&v)},
	)
	return ok
}

game_object_new :: proc (name: string) -> (GameObject, bool) {
	class, cok := il2cpp.find_class("UnityEngine.GameObject")
	if !cok {
		return GameObject(0), false
	}
	obj := GameObject(il2cpp.object_new(class))
	if obj == 0 {
		return GameObject(0), false
	}
	arg := il2cpp.string_new(name)
	_, ok := invoke_named(
		il2cpp.Il2CppObject(obj),
		"UnityEngine.GameObject",
		".ctor",
		[]string {"System.String"},
		[]uintptr {uintptr(&arg)},
	)
	return obj, ok
}

game_object_get_full_path :: proc (go: GameObject) -> string {
	parts := [dynamic]string{}
	defer delete(parts)
	cur := go
	for cur != 0 {
		if n, nok := game_object_get_name(cur); nok && n != 0 {
			s, _ := il2cpp.string_to_utf8(n, context.temp_allocator)
			append(&parts, s)
		} else {
			break
		}
		t, tok := game_object_get_transform(cur)
		if !tok {
			break
		}
		p, pok := transform_get_parent(t)
		if !pok || p == 0 {
			break
		}
		g, gok := transform_get_game_object(p)
		if !gok {
			break
		}
		cur = g
	}
	if len(parts) == 0 {
		return ""
	}
	b := strings.Builder{}
	strings.write_string(&b, parts[len(parts) - 1])
	for i := len(parts) - 2; i >= 0; i -= 1 {
		strings.write_byte(&b, '/')
		strings.write_string(&b, parts[i])
	}
	return strings.to_string(b)
}

game_object_find_active_character :: proc (path: string) -> (GameObject, bool) {
	root, ok := game_object_find(path)
	if !ok || root == 0 {
		return GameObject(0), false
	}
	t, tok := game_object_get_transform(root)
	if !tok {
		return GameObject(0), false
	}
	n, nok := transform_get_child_count(t)
	if !nok || n == 0 {
		return GameObject(0), false
	}
	for i: i32 = 0; i < n; i += 1 {
		ct, cok := transform_get_child(t, i)
		if !cok {
			continue
		}
		cg, cgok := transform_get_game_object(ct)
		if !cgok {
			continue
		}
		act, aok := game_object_active_in_hierarchy(cg)
		if aok && act {
			return cg, true
		}
	}
	return GameObject(0), false
}

game_object_get_component_names :: proc (go: GameObject) -> string {
	class, _ := il2cpp.find_class("UnityEngine.Component")
	if class == 0 {
		return ""
	}
	arr, ok := game_object_get_components(go, reflection.runtime_type_of_class(class))
	if !ok {
		return ""
	}
	n := il2cpp.array_length(arr)
	b := strings.Builder{}
	for i: uintptr = 0; i < n; i += 1 {
		c := Component(il2cpp.array_get(arr, i, il2cpp.Il2CppObject))
		if c == 0 {
			continue
		}
		cl := il2cpp.typeof(il2cpp.Il2CppObject(c))
		nm := string(il2cpp.vm_il2cpp_class_get_name(cl))
		ns := string(il2cpp.vm_il2cpp_class_get_namespace(cl))
		if i > 0 {
			strings.write_string(&b, ", ")
		}
		if ns != "" {
			strings.write_string(&b, ns)
			strings.write_byte(&b, '.')
		}
		strings.write_string(&b, nm)
	}
	return strings.to_string(b)
}

game_object_find_character_obj :: proc (
	parent:    Transform,
	child_name: Maybe(string),
) -> (GameObject, bool) {
	if parent == 0 {
		return GameObject(0), false
	}
	n, nok := transform_get_child_count(parent)
	if !nok {
		return GameObject(0), false
	}
	for i: i32 = 0; i < n; i += 1 {
		ct, cok := transform_get_child(parent, i)
		if !cok {
			continue
		}
		cg, cgok := transform_get_game_object(ct)
		if !cgok {
			continue
		}
		if child_name != nil {
			if nm, nmok := game_object_get_name(cg); nmok {
				if s, _ := il2cpp.string_to_utf8(nm, context.temp_allocator); s == child_name.? {
					return cg, true
				}
			}
		}
		if found, fok := game_object_find_character_obj(ct, child_name); fok {
			return found, true
		}
	}
	return GameObject(0), false
}