extends BaseMove
class_name SkeletonMove

@export var speed: float = 5.0
var can_move: bool = false
var velocity: Vector3 = Vector3.ZERO
var input: SkeletonInput
var state: SkeletonState
@export var nav_agent: NavigationAgent3D

func _setup():
	entity.connect("ready_for_movement", Callable(self, "_on_ready_for_movement"))
	input = entity.get_component(SkeletonInput)
	state = entity.get_component(SkeletonState)
	if state:
		state.connect("state_changed", Callable(self, "_on_state_changed"))
	if nav_agent:
		nav_agent.avoidance_enabled = true
		nav_agent.radius = 1  # Adjust to your unit size
		nav_agent.neighbor_distance = 5.0  # Distance to consider neighbors
		nav_agent.time_horizon = 1.0
		nav_agent.max_neighbors = 10
		nav_agent.velocity_computed.connect(_on_velocity_computed)
	start_initial_rise()

func physics_process(delta: float):
	if not can_move or not state or not input or not state.is_ready_for_movement():
		velocity = Vector3.ZERO
		return

	var next_pos = nav_agent.get_next_path_position()
	var intended_velocity = (next_pos - entity.global_position).normalized() * speed
	nav_agent.velocity = intended_velocity  # Trigger avoidance computation

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

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	velocity.y = 0
	entity.velocity = velocity
	entity.move_and_slide()
