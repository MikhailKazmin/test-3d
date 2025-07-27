# GatherMarkEffect.gd
extends Object
class_name GatherMarkEffect

func apply(center: Vector3, radius: float, caller: Node) -> void:
	var gatherables = caller.get_tree().get_nodes_in_group("Gatherables")
	var to_mark: Array = []

	for gatherable in gatherables:
		if gatherable is Gatherable and center.distance_to(gatherable.global_position) <= radius:
			var res_state = gatherable.components["state"] as ResourceState
			if res_state and not res_state.is_depleted and not res_state.is_marked:
				to_mark.append(gatherable)

	if to_mark.is_empty():
		return

	for gatherable in to_mark:
		var res_state = gatherable.components["state"] as ResourceState
		if res_state:
			res_state.is_marked = true
			if res_state.mark:
				res_state.mark.visible = true
