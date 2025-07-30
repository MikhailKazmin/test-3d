# systems/RotateSystem.gd
extends Node
class_name RotateSystem

var ecs_manager: ECSManager
var required_mask: int

func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask("Rotate") | ComponentType.get_mask("Navigation") | ComponentType.get_mask("State") | ComponentType.get_mask("Gathering") | ComponentType.get_mask("CharacterBody3D") | ComponentType.get_mask("Position")

func _physics_process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	for entity in entities:
		var rotate_comp = entity.get_component(ComponentType.get_mask("Rotate"))
		var nav_comp = entity.get_component(ComponentType.get_mask("Navigation"))
		var state_comp = entity.get_component(ComponentType.get_mask("State"))
		var gath_comp = entity.get_component(ComponentType.get_mask("Gathering"))
		var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
		var pos_comp = entity.get_component(ComponentType.get_mask("Position"))
		var dir: Vector3
		if state_comp.current_state == SkeletonState.State.GATHERING and gath_comp.current_resource:
			dir = (gath_comp.current_resource.global_position - pos_comp.position).normalized()
		else:
			dir = nav_comp.direction
		dir.y = 0
		if dir.length() > 0.01:
			var target_angle = atan2(dir.x, dir.z)
			body_comp.rig.rotation.y = lerp_angle(body_comp.rig.rotation.y, target_angle, rotate_comp.rotation_speed * delta)
