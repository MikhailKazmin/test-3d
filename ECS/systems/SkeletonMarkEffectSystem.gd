# systems/SkeletonMarkEffectSystem.gd
extends Node
class_name SkeletonMarkEffectSystem

var ecs_manager: ECSManager
var required_mask: int

func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask(ComponentType.Name.Position) \
		| ComponentType.get_mask(ComponentType.Name.State) \
		| ComponentType.get_mask(ComponentType.Name.Mark)  # если есть

func apply(center: Vector3, radius: float) -> void:
	var entities = ecs_manager.filter_entities(required_mask)
	for entity in entities:
		var pos_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
		if not state_comp.is_selected and center.distance_to(pos_comp.position) <= radius:
			state_comp.is_selected = true
			var mark_comp = null
			if ComponentType.get_mask(ComponentType.Name.Mark):
				mark_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Mark))
			if mark_comp and mark_comp.mark:
				mark_comp.mark.visible = true
