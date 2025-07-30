# systems/RandomMovementSystem.gd
extends Node
class_name RandomMovementSystem

var ecs_manager: ECSManager
var required_mask: int

func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask("RandomMovement") | ComponentType.get_mask("Navigation") | ComponentType.get_mask("Position")

func _process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	
	for entity in entities:
		var rand_comp = entity.get_component(ComponentType.get_mask("RandomMovement"))
		var nav_comp = entity.get_component(ComponentType.get_mask("Navigation"))
		var pos_comp = entity.get_component(ComponentType.get_mask("Position"))
		if nav_comp.target_position.distance_to(pos_comp.position) < 0.1:
			var min_distance = 5.0
			var new_pos: Vector3
			while true: 
				new_pos = pos_comp.position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
				if new_pos.distance_to(pos_comp.position) >= min_distance:
					break
			nav_comp.target_position = new_pos
			
