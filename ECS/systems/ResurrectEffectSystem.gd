extends Node
class_name ResurrectEffectSystem

var ecs_manager: ECSManager
var required_mask: int

func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask(ComponentType.Name.Effect)

func _process(delta):
	var effect_entities = ecs_manager.filter_entities(required_mask)
	for effect_entity in effect_entities:
		var effect_comp = effect_entity.get_component(ComponentType.get_mask(ComponentType.Name.Effect))
		if effect_comp.effect_type != "resurrect":
			continue

		effect_comp.elapsed += delta
		if effect_comp.elapsed < effect_comp.duration:
			# Время каста ещё идёт, можно визуализировать что-то тут
			continue

		# По завершению каста — находим трупы, которые нужно воскресить
		var corpse_entities = ecs_manager.filter_entities(ComponentType.get_mask(ComponentType.Name.Corpse) | \
			ComponentType.get_mask(ComponentType.Name.Position))
		var to_revive: Array = []

		for corpse_entity in corpse_entities:
			var pos_comp = corpse_entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
			if effect_comp.center.distance_to(pos_comp.position) <= effect_comp.radius:
				to_revive.append(corpse_entity)

		# Воскрешаем трупы
		for corpse_entity in to_revive:
			var corpse_comp = corpse_entity.get_component(ComponentType.get_mask(ComponentType.Name.Corpse))
			var pos_comp = corpse_entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
			# Создаём новый экземпляр "живого" существа:
			var prefab = corpse_comp.prefab
			var new_instance = prefab.instantiate()
			new_instance.global_position = pos_comp.position
			# Добавляем в сцену
			ecs_manager.add_child(new_instance)
			# Удаляем труп из ECS
			ecs_manager.remove_entity(corpse_entity)

		# Эффект отработал — удаляем эффект-entity
		ecs_manager.remove_entity(effect_entity)
