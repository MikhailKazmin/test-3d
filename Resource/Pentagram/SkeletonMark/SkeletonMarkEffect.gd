extends Object
class_name SkeletonMarkEffect

func apply(center: Vector3, radius: float, caller: Node, world: World) -> void:
	var ecs_manager = world.ecs_manager

	# Ищем всех скелетов: сущности с компонентами State и Position
	var required_mask = ComponentType.get_mask(ComponentType.Name.State) | ComponentType.get_mask(ComponentType.Name.Position)
	var entities = ecs_manager.filter_entities(required_mask)

	var to_mark: Array = []

	for entity in entities:
		var pos_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
		if not pos_comp or not state_comp:
			continue

		# Скелет должен быть в радиусе и не выбран
		if center.distance_to(pos_comp.position) <= radius and not state_comp.is_selected:
			to_mark.append(state_comp)

	if to_mark.is_empty():
		return

	for state_comp in to_mark:
		state_comp.is_selected = true
		if state_comp.mark:
			state_comp.mark.visible = true
