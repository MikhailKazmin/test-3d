# systems/FormationEffectSystem.gd
extends Node
class_name FormationEffectSystem

var ecs_manager: ECSManager
var required_mask: int

func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask(ComponentType.Name.Position) \
		| ComponentType.get_mask(ComponentType.Name.State) \
		| ComponentType.get_mask(ComponentType.Name.Formation)

func apply(center: Vector3, radius: float, unit_spacing: float = 2.0, row_spacing: float = 3.0, margin: float = 1.0) -> void:
	var entities = ecs_manager.filter_entities(required_mask)
	var to_form: Array = []

	for entity in entities:
		var pos_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
		if state_comp.is_selected and center.distance_to(pos_comp.position) <= radius:
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
		var target_pos = center + Vector3(col_offset, 0, row_offset)
		var dist = Vector2(target_pos.x - center.x, target_pos.z - center.z).length()
		if dist > radius - margin:
			var dir = (target_pos - center).normalized()
			target_pos = center + dir * (radius - margin)
		var formation_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Formation))
		formation_comp.formation_target = target_pos

		current_col += 1
		if current_col >= num_per_row:
			current_col = 0
			current_row += 1
