# ecs/Entity.gd
extends Node
class_name Entity

var id: int = -1
var components: Dictionary = {}
var component_mask: int = 0
var ecs_manager: ECSManager = null

func add_component(component: Resource, type_mask: int) -> void:
	if type_mask == 0:
		printerr("Warning: Adding component with mask 0 for entity #%d" % id)
	components[type_mask] = component
	component_mask |= type_mask
	if ecs_manager:
		ecs_manager._on_component_changed(self)

func remove_component(type_mask: int) -> void:
	components.erase(type_mask)
	component_mask &= ~type_mask
	if ecs_manager:
		ecs_manager._on_component_changed(self)

func get_component(type_mask: int) -> Resource:
	return components.get(type_mask, null)

func has_components(required_mask: int) -> bool:
	return (component_mask & required_mask) == required_mask
