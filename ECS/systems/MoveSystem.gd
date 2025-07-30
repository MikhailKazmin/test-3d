# systems/MoveSystem.gd
extends Node
class_name MoveSystem

var ecs_manager: ECSManager
var required_mask: int

func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask("Move") | ComponentType.get_mask("Navigation") | ComponentType.get_mask("State") | ComponentType.get_mask("CharacterBody3D") | ComponentType.get_mask("Position")

func _physics_process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	
	for entity in entities:
		var move_comp = entity.get_component(ComponentType.get_mask("Move"))
		var nav_comp = entity.get_component(ComponentType.get_mask("Navigation"))
		var state_comp = entity.get_component(ComponentType.get_mask("State"))
		var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
		var pos_comp = entity.get_component(ComponentType.get_mask("Position"))
		if not move_comp or not body_comp or not pos_comp or state_comp.current_state == StateComponent.State.GATHERING:
			if body_comp:
				body_comp.character_body_3d.velocity = Vector3.ZERO
			continue
		if body_comp.character_body_3d != null:
			body_comp.character_body_3d.velocity = nav_comp.direction * move_comp.speed
			body_comp.character_body_3d.move_and_slide()
			pos_comp.position = body_comp.character_body_3d.global_position
			move_comp.velocity = body_comp.character_body_3d.velocity
			body_comp.character_body_3d.global_position = pos_comp.position  # Синхронизация
		
