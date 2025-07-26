extends BaseResourceComponent
class_name ResourceInteraction

var is_depleted: bool = false

func _setup():
	var state = entity.components["state"] as ResourceState
	if state:
		is_depleted = state.is_depleted
