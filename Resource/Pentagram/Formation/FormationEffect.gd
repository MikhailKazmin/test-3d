# FormationEffect.gd
extends Object
class_name FormationEffect

@export var unit_spacing: float = 2.0  # Расстояние между юнитами в ряду
@export var row_spacing: float = 3.0  # Расстояние между рядами
@export var margin: float = 1.0  # Отступ от края круга

func apply(center: Vector3, radius: float, caller: Node) -> void:
	var units = caller.get_tree().get_nodes_in_group("Skeletons")  # Предполагаем группу "Units" для скелетов/юнитов
	var to_form: Array = []

	for unit in units:
		if unit is Node3D:
			var unit_state = unit.components["state"] as SkeletonState
			#var unit_state = unit.components["state"] if "components" in unit and "state" in unit.components else null
			if unit_state and unit_state.is_selected:
				to_form.append(unit)

	if to_form.is_empty():
		return

	var n = to_form.size()
	var max_row_length = (radius - margin) * 2.0  # Максимальная длина ряда внутри круга

	# Рассчитываем максимальное количество юнитов в ряду
	var max_per_row = floor(max_row_length / unit_spacing) + 1

	# Если один ряд не помещается, увеличиваем количество рядов
	var num_rows = ceil(float(n) / max_per_row)
	var num_per_row = ceil(float(n) / num_rows)  # Перераспределяем для баланса

	# Рассчитываем смещение для центрирования формации
	var half_rows = (num_rows - 1) / 2.0 * row_spacing
	var current_row = 0
	var current_col = 0

	for unit in to_form:
		var row_offset = (current_row - (num_rows - 1) / 2.0) * row_spacing
		var col_offset = (current_col - (num_per_row - 1) / 2.0) * unit_spacing

		# Позиция относительно центра (предполагаем плоскость XZ, Y - высота)
		var target_pos = center + Vector3(col_offset, 0, row_offset)

		# Проверяем, вписывается ли в круг
		var dist = Vector2(target_pos.x - center.x, target_pos.z - center.z).length()
		if dist > radius - margin:
			# Если выходит, можно скорректировать spacing или предупредить
			print("Warning: Unit position outside radius, adjusting...")
			var dir = (target_pos - center).normalized()
			target_pos = center + dir * (radius - margin)

		# Устанавливаем точку передвижения в input компоненте
		var formation_comp = unit.get_component(SkeletonFormation)
		if formation_comp:
			formation_comp.set_formation_target(target_pos)

		current_col += 1
		if current_col >= num_per_row:
			current_col = 0
			current_row += 1
