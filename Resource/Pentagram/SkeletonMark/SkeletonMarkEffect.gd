# SkeletonMarkEffect.gd
extends Object
class_name SkeletonMarkEffect

func apply(center: Vector3, radius: float, caller: Node) -> void:
	var skeletons = caller.get_tree().get_nodes_in_group("Skeletons")
	var to_mark: Array = []

	for skeleton in skeletons:
		if skeleton is Node3D and center.distance_to(skeleton.global_position) <= radius:
			var skel_state = skeleton.components["state"] as SkeletonState
			if skel_state and not skel_state.is_selected:
				to_mark.append(skeleton)

	if to_mark.is_empty():
		return

	for skeleton in to_mark:
		var skel_state = skeleton.components["state"]
		if skel_state:
			skel_state.is_selected = true
			if skel_state.mark:
				skel_state.mark.visible = true
