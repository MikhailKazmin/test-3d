# systems/RandomMovementSystem.gd
extends Node
class_name RandomMovementSystem

var ecs_manager: ECSManager
var required_mask: int


func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask("RandomMovement") | ComponentType.get_mask("Navigation") | ComponentType.get_mask("Position") | ComponentType.get_mask("CharacterBody3D")

func _process(delta):
	var entities = ecs_manager.filter_entities(required_mask)

	for entity in entities:
		var nav_comp: NavigationComponent = entity.get_component(ComponentType.get_mask("Navigation"))
		var pos_comp = entity.get_component(ComponentType.get_mask("Position"))
		var char_comp: CharacterBody3DComponent = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
		var state_comp = entity.get_component(ComponentType.get_mask("State"))
		if char_comp == null or char_comp.nav_agent == null:
			continue
		# Проверяем, что юнит в состоянии IDLE
		if state_comp.current_state != StateComponent.State.IDLE:
			continue
		if char_comp.nav_agent.is_navigation_finished():
			var min_distance = 5.0
			var new_pos: Vector3
			while true:
				new_pos = pos_comp.position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
				if new_pos.distance_to(pos_comp.position) >= min_distance:
					break
			nav_comp.target_position = new_pos

			
