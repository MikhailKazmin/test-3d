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
		# Проверяем, что все компоненты существуют и юнит в состоянии IDLE или MOVING
		if not move_comp or not body_comp or not body_comp.character_body_3d or not pos_comp or \
			not (state_comp.current_state in [StateComponent.State.IDLE, StateComponent.State.MOVING]) or \
			not move_comp.can_move:
			if body_comp and body_comp.character_body_3d:
				body_comp.character_body_3d.velocity = Vector3.ZERO
			continue
		# Применяем движение
		body_comp.character_body_3d.velocity = nav_comp.direction * move_comp.speed
		body_comp.character_body_3d.move_and_slide()
		pos_comp.position = body_comp.character_body_3d.global_position
		# Проверяем, существует ли компонент Velocity для хранения скорости
		var velocity_comp = entity.get_component(ComponentType.get_mask("Velocity"))
		if velocity_comp:
			velocity_comp.velocity = body_comp.character_body_3d.velocity
		body_comp.character_body_3d.global_position = pos_comp.position  # Синхронизация
		
