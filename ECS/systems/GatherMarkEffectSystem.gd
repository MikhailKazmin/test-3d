# systems/GatherMarkEffectSystem.gd
extends Node
class_name GatherMarkEffectSystem

var ecs_manager: ECSManager
var required_mask: int

func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask(ComponentType.Name.Position) \
		| ComponentType.get_mask(ComponentType.Name.Gatherable) \
		| ComponentType.get_mask(ComponentType.Name.ResourceState)

func apply(center: Vector3, radius: float) -> void:
	var entities = ecs_manager.filter_entities(required_mask)
	for entity in entities:
		var pos_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.ResourceState))
		if not state_comp.is_depleted and not state_comp.is_marked and center.distance_to(pos_comp.position) <= radius:
			state_comp.is_marked = true
			if state_comp.mark:
				state_comp.mark.visible = true
