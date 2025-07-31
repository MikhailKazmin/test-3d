# systems/RotateSystem.gd
extends Node
class_name RotateSystem

var ecs_manager: ECSManager
var required_mask: int


func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask(ComponentType.Name.Rotate) | \
	ComponentType.get_mask(ComponentType.Name.Navigation) | \
	ComponentType.get_mask(ComponentType.Name.State) | \
	ComponentType.get_mask(ComponentType.Name.Gathering) | \
	ComponentType.get_mask(ComponentType.Name.CharacterBody3D) | \
	ComponentType.get_mask(ComponentType.Name.Position)

func _physics_process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	for entity in entities:
		var rotate_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Rotate))
		var nav_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Navigation))
		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
		var gath_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Gathering))
		var body_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
		var pos_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		var dir: Vector3
		if state_comp.current_state == SkeletonState.State.GATHERING and gath_comp.current_resource:
			dir = (gath_comp.current_resource.global_position - pos_comp.position).normalized()
		else:
			dir = nav_comp.direction
		dir.y = 0
		if dir.length() > 0.01:
			var target_angle = atan2(dir.x, dir.z)
			body_comp.rig.rotation.y = lerp_angle(body_comp.rig.rotation.y, target_angle, rotate_comp.rotation_speed * delta)
