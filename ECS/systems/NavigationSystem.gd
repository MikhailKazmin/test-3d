# systems/NavigationSystem.gd
extends Node
class_name NavigationSystem

var ecs_manager: ECSManager
var required_mask: int


func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask("Navigation") | ComponentType.get_mask("CharacterBody3D") | ComponentType.get_mask("Position")

func _process(delta):
	var entities = ecs_manager.filter_entities(required_mask)

	for entity in entities:
		var nav_comp = entity.get_component(ComponentType.get_mask("Navigation"))
		var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
		var pos_comp = entity.get_component(ComponentType.get_mask("Position"))
		if body_comp.character_body_3d != null:
			body_comp.nav_agent.target_position = nav_comp.target_position
			if body_comp.nav_agent.is_navigation_finished():
				nav_comp.direction = Vector3.ZERO
			else:
				var next_pos = body_comp.nav_agent.get_next_path_position()
				nav_comp.direction = (next_pos - pos_comp.position).normalized()
				nav_comp.direction.y = 0
			
