extends Object
class_name ResurrectEffect

func apply(center: Vector3, radius: float, caller: Node, world: World) -> void:
	var corpses = []
	# Получаем ссылку на ecs_manager (или world.entities)
	var ecs_manager = world.ecs_manager

	# Собираем все сущности с компонентом State и Position
	var required_mask = ComponentType.get_mask(ComponentType.Name.State) | ComponentType.get_mask(ComponentType.Name.Position)
	var entities = ecs_manager.filter_entities(required_mask)
	
	for entity in entities:
		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
		var pos_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		
		# Предполагаем, что труп — это сущность в DEATH_POSE
		if state_comp.current_state == StateComponent.State.DEATH_POSE:
			if center.distance_to(pos_comp.position) <= radius:
				corpses.append(entity)
	
	if corpses.is_empty():
		return

	# Анимация: поднимаем все трупы вниз на 2 ед. (как раньше)
	var tween = caller.create_tween()
	for entity in corpses:
		var body_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
		if body_comp and body_comp.character_body_3d:
			tween = tween.parallel()
			tween.tween_property(body_comp.character_body_3d, "position:y", body_comp.character_body_3d.position.y - 2.0, 1.0)
	await tween.finished

	# Собираем координаты и удаляем старые сущности
	var dict: Dictionary = {}
	for i in range(corpses.size()):
		var entity = corpses[i]
		var body_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
		if body_comp and body_comp.character_body_3d:
			dict[i] = body_comp.character_body_3d.global_position
			# Удаляем 3D-объект (corpse) из сцены!
			body_comp.character_body_3d.queue_free()
		# Удаляем сущность через ecs_manager
		ecs_manager.remove_entity(entity)
			
	
	world.create_entity(dict)
