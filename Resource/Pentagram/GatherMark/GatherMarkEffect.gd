extends Object
class_name GatherMarkEffect

func apply(center: Vector3, radius: float, caller: Node, world: World) -> void:
	var ecs_manager = world.ecs_manager
	var required_mask = ComponentType.get_mask(ComponentType.Name.Gatherable) | ComponentType.get_mask(ComponentType.Name.Position)
	var entities = ecs_manager.filter_entities(required_mask)

	for entity in entities:
		var pos_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		var gatherable_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Gatherable))
		if not pos_comp or not gatherable_comp:
			continue

		if center.distance_to(pos_comp.position) <= radius:
			if not gatherable_comp.is_depleted and not gatherable_comp.is_marked:
				gatherable_comp.is_marked = true
				if gatherable_comp.mark:
					gatherable_comp.mark.visible = true
