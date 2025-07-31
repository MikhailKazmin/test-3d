extends BaseComponentComposition
class_name SkeletonFormation

var formation_target: Vector3 = Vector3.ZERO

var navigation: SkeletonNavigation
var state: SkeletonState

func _setup() -> void:
	navigation = entity.get_component(SkeletonNavigation)
	state = entity.get_component(SkeletonState)

func process(delta: float) -> void:
	if formation_target != Vector3.ZERO:
		navigation.set_target_position(formation_target)
		if navigation.is_navigation_finished():
			formation_target = Vector3.ZERO
			if state:
				state.set_state(SkeletonState.State.IDLE)
		else:
			navigation.direction = navigation.update_direction()  # Обновляем общее направление через Input

func set_formation_target(target: Vector3) -> void:
	formation_target = target
