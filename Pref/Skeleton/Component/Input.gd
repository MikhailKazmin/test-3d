extends BaseInput
class_name SkeletonInput

var can_control: bool = false
var direction: Vector3 = Vector3.ZERO  # Оставляем как общее направление
var state: SkeletonState

@export var update_interval: float = 0.1
var accumulated_delta: float = 0.0

var navigation: SkeletonNavigation
var gathering: SkeletonGathering
var random_movement: SkeletonRandomMovement
var formation: SkeletonFormation

func _setup():
	entity.connect("ready_for_movement", Callable(self, "_on_ready_for_movement"))
	var animation = entity.get_component(SkeletonAnimation)
	if animation:
		animation.connect("gather_animation_finished", Callable(self, "_on_gather_animation_finished"))
	state = entity.get_component(SkeletonState)
	if state:
		state.connect("state_changed", Callable(self, "_on_state_changed"))

	navigation = entity.get_component(SkeletonNavigation)
	gathering = entity.get_component(SkeletonGathering)
	random_movement = entity.get_component(SkeletonRandomMovement)
	formation = entity.get_component(SkeletonFormation)

func physics_process(delta: float):
	accumulated_delta += delta
	if accumulated_delta >= update_interval:
		_perform_logic(delta)
		accumulated_delta -= update_interval

func _perform_logic(delta: float):
	if not can_control or not state or not state.is_ready_for_movement():
		direction = Vector3.ZERO
		return

	if gathering and gathering.current_resource and is_instance_valid(gathering.current_resource):
		# Только добываем, не двигаемся
		gathering.process(delta)
		direction = Vector3.ZERO
	elif formation and formation.formation_target != Vector3.ZERO:
		formation.process(delta)
	else:
		if gathering:
			gathering.process(delta)
		if random_movement:
			random_movement.process(delta)



func _on_ready_for_movement():
	can_control = true

func _on_gather_animation_finished(resource):
	if gathering:
		gathering.reset_gathering()
	if state:
		state.set_state(SkeletonState.State.IDLE)

func _on_state_changed(new_state: int):
	pass
