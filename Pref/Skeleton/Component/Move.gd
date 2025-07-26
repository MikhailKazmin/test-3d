extends BaseMove
class_name SkeletonMove

@export var speed: float = 5.0
var can_move: bool = false
var velocity: Vector3 = Vector3.ZERO
var input: SkeletonInput
var state: SkeletonState

func _setup():
	entity.connect("ready_for_movement", Callable(self, "_on_ready_for_movement"))
	input = entity.get_component(SkeletonInput)
	state = entity.get_component(SkeletonState)
	if state:
		state.connect("state_changed", Callable(self, "_on_state_changed"))
	start_initial_rise()

func physics_process(delta: float):
	if not can_move or not state or not input or not state.is_ready_for_movement():
		velocity = Vector3.ZERO
		return

	velocity = input.direction * speed
	entity.velocity = velocity
	entity.move_and_slide()

func start_initial_rise():
	if state:
		state.set_state(SkeletonState.State.RISING)
	entity.emit_signal("rise_started")
	var tween = create_tween()
	tween.tween_property(entity, "global_transform:origin:y", entity.global_position.y + 2, 1.0)
	await tween.finished
	if state:
		state.set_state(SkeletonState.State.IDLE)
	entity.emit_signal("rise_completed")

func _on_ready_for_movement():
	can_move = true

func _on_state_changed(new_state: int):
	pass
