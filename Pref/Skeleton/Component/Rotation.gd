extends BaseComponent
class_name SkeletonRotate

@export var rotation_speed: float = 8.0
@onready var rig: Node3D = $"../../Rig"
var input: SkeletonInput
var state: SkeletonState

func _setup():
	input = entity.get_component(SkeletonInput)
	state = entity.get_component(SkeletonState)
	if state:
		state.connect("state_changed", Callable(self, "_on_state_changed"))

func physics_process(delta: float):
	if not state or not input:
		return

	if state.current_state == SkeletonState.State.GATHERING:
		if input.current_resource and is_instance_valid(input.current_resource):
			var direction = (input.current_resource.global_position - entity.global_position).normalized()
			direction.y = 0
			if direction.length() > 0.01:
				var target_angle = atan2(direction.x, direction.z)
				rig.rotation.y = lerp_angle(rig.rotation.y, target_angle, rotation_speed * delta)
	else:
		if not state.is_ready_for_movement():
			return
		var direction = input.direction
		if direction.length() > 0.01:
			var target_angle = atan2(direction.x, direction.z)
			rig.rotation.y = lerp_angle(rig.rotation.y, target_angle, rotation_speed * delta)

func _on_state_changed(new_state: int):
	pass
