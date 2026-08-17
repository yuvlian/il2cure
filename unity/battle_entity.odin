package unity

import "../il2cpp"

BattleEntity :: distinct il2cpp.Il2CppObject

battle_entity_get_root :: proc (e: BattleEntity) -> (GameObject, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(e),
		"MoleMole.Battle.Entity",
		"get_Root",
	)
	return GameObject(res), ok && res != 0
}

battle_entity_set_root :: proc (e: BattleEntity, value: GameObject) -> bool {
	_, ok := invoke_named(
		il2cpp.Il2CppObject(e),
		"MoleMole.Battle.Entity",
		"set_Root",
		[]string {"UnityEngine.GameObject"},
		[]uintptr {uintptr(value)},
	)
	return ok
}

battle_entity_get_root_transform :: proc (e: BattleEntity) -> (Transform, bool) {
	res, ok := invoke_named(
		il2cpp.Il2CppObject(e),
		"MoleMole.Battle.Entity",
		"get_RootTransform",
	)
	return Transform(res), ok && res != 0
}