extends Object
class_name FormationEffect

@export var unit_spacing: float = 2.0  # Расстояние между юнитами в ряду
@export var row_spacing: float = 3.0   # Расстояние между рядами
@export var margin: float = 1.0        # Отступ от края круга

func apply(center: Vector3, radius: float, caller: Node, world: World) -> void:
	var ecs_manager = world.ecs_manager

	# Ищем всех скелетов: State + Position + Formation компоненты
	var required_mask = ComponentType.get_mask(ComponentType.Name.State) | ComponentType.get_mask(ComponentType.Name.Position) | ComponentType.get_mask(ComponentType.Name.Formation)
	var entities = ecs_manager.filter_entities(required_mask)

	var to_form: Array = []

	for entity in entities:
		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
		if state_comp and state_comp.is_selected:
			to_form.append(entity)

	if to_form.is_empty():
		return

	var n = to_form.size()
	var max_row_length = (radius - margin) * 2.0
	var max_per_row = floor(max_row_length / unit_spacing) + 1
	var num_rows = ceil(float(n) / max_per_row)
	var num_per_row = ceil(float(n) / num_rows)
	var current_row = 0
	var current_col = 0

	for entity in to_form:
		var row_offset = (current_row - (num_rows - 1) / 2.0) * row_spacing
		var col_offset = (current_col - (num_per_row - 1) / 2.0) * unit_spacing

		# Новая цель на плоскости XZ
		var target_pos = center + Vector3(col_offset, 0, row_offset)

		# Проверяем, чтобы не выйти за радиус
		var dist = Vector2(target_pos.x - center.x, target_pos.z - center.z).length()
		if dist > radius - margin:
			var dir = (target_pos - center).normalized()
			target_pos = center + dir * (radius - margin)

		var formation_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Formation))
		if formation_comp:
			formation_comp.formation_target = target_pos

		current_col += 1
		if current_col >= num_per_row:
			current_col = 0
			current_row += 1
