extends BaseComponent
class_name SkeletonRandomMovement

var _last_random_target: Vector3 = Vector3.INF

var navigation: SkeletonNavigation

func _setup() -> void:
	navigation = entity.get_component(SkeletonNavigation)
	set_random_target()

func process(delta: float) -> void:
	if navigation.is_navigation_finished():
		set_random_target()
	entity.get_component(SkeletonInput).direction = navigation.update_direction()  # Обновляем общее направление через Input

func set_random_target() -> void:
	var min_distance = 5.0
	var new_pos: Vector3
	while true:
		new_pos = entity.global_position + Vector3(randf() * 20 - 10, 0, randf() * 20 - 10)
		if new_pos.distance_to(entity.global_position) >= min_distance:
			break
	navigation.set_target_position(new_pos)
