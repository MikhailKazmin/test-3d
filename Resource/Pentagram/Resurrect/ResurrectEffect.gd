extends Object
class_name ResurrectEffect

func apply(center: Vector3, radius: float, caller: Node, world: World) -> void:
	var corpses = caller.get_tree().get_nodes_in_group("Corpses")
	var to_revive: Array = []

	for corpse in corpses:
		if corpse is Node3D and center.distance_to(corpse.global_position) <= radius:
			to_revive.append(corpse)

	if to_revive.is_empty():
		return

	var tween = caller.create_tween()
	for corpse in to_revive:
		tween = tween.parallel()
		tween.tween_property(corpse, "position:y", corpse.position.y - 2.0, 1.0)
	await tween.finished
	
	var dict:Dictionary = {}
	for i: int in range(0, to_revive.size()):
		dict[i] = to_revive[i].global_position
		to_revive[i].queue_free()
	world.create_entity(dict)
