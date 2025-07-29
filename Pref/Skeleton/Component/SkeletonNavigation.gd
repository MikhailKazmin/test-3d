extends BaseComponent
class_name SkeletonNavigation

@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"

var direction: Vector3 = Vector3.ZERO

func set_target_position(target: Vector3) -> void:
	nav_agent.set_target_position(target)

func is_navigation_finished() -> bool:
	return nav_agent.is_navigation_finished()

func update_direction() -> Vector3:
	if nav_agent.is_navigation_finished():
		return Vector3.ZERO
	var next_path_pos = nav_agent.get_next_path_position()
	direction = (next_path_pos - entity.global_position).normalized()
	direction.y = 0
	return direction
