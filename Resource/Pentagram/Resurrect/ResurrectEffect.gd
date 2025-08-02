extends Object
class_name ResurrectEffect

func apply(center: Vector3, radius: float, caller: Node) -> void:
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

	for corpse in to_revive:
		if corpse.has_method("get_new_prefab"):
			var new_instance = corpse.get_new_prefab().instantiate()
			new_instance.global_position = corpse.global_position
			caller.get_tree().current_scene.add_child(new_instance)
		corpse.queue_free()
