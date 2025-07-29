extends BaseMove
class_name SkeletonMove

@export var speed: float = 5.0
var can_move: bool = false

var navigation: SkeletonNavigation
var state: SkeletonState
@export var nav_agent: NavigationAgent3D

func _setup():
	entity.connect("ready_for_movement", Callable(self, "_on_ready_for_movement"))
	navigation = entity.get_component(SkeletonNavigation)
	state = entity.get_component(SkeletonState)
	if state:
		state.connect("state_changed", Callable(self, "_on_state_changed"))
	if nav_agent:
		nav_agent.avoidance_priority = randf()  # Случайный приоритет (0-1), чтобы юниты "уступали" по-разному
		#nav_agent.velocity_computed.connect(_on_velocity_computed)
	start_initial_rise()

func physics_process(delta: float):
	if not can_move or not state or not navigation or not state.is_ready_for_movement():
		entity.velocity = Vector3.ZERO
		return

	entity.velocity = navigation.direction * speed
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

func _on_velocity_computed(safe_velocity: Vector3):
	entity.velocity = safe_velocity
	entity.velocity.y = 0  # Уже есть, но убедитесь, что terrain flat
	if entity.velocity.length() < 0.1 and not nav_agent.is_navigation_finished():
		print("Малая velocity, толкаем/repah")
		# Вариант 1: Толчок в направлении
		entity.velocity += navigation.direction.normalized() * speed * 0.2  # Малый boost
		# Вариант 2: Force repath
		#nav_agent.set_target_position(nav_agent.get_target_position())
	entity.move_and_slide()
