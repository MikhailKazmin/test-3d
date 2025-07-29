extends BaseAnimation
class_name SkeletonAnimation

signal gather_animation_finished(resource)

var is_gathering_anim := false
@export var animation_player: AnimationPlayer
var last_animation := ""
var current_phase: String = "rising"
var can_move: bool = false
var state: SkeletonState

func _setup():
	# Подписываемся на события entity
	entity.connect("ready_for_movement", Callable(self, "_on_ready_for_movement"))
	if entity.has_signal("rise_completed"):
		entity.connect("rise_completed", Callable(self, "_on_rise_completed"))
	if entity.has_signal("gather_resource"):
		entity.connect("gather_resource", Callable(self, "_on_gather_resource"))
	state = entity.get_component(SkeletonState)
	if state:
		state.connect("state_changed", Callable(self, "_on_state_changed"))

func _ready():
	# Начинаем последовательность анимаций
	_start_death_pose()

func _start_death_pose():
	if state:
		state.set_state(SkeletonState.State.DEATH_POSE)
	current_phase = "death_pose"
	play_anim("Death_A_Pose")
	await get_tree().create_timer(2.0).timeout
	_start_stand_up()

func _start_stand_up():
	if state:
		state.set_state(SkeletonState.State.STANDING_UP)
	current_phase = "standing_up"
	play_anim("Lie_StandUp")
	await animation_player.animation_finished
	_complete_sequence()

func _complete_sequence():
	if state:
		state.set_state(SkeletonState.State.IDLE)
	current_phase = "idle"
	play_anim("Idle")
	if entity.has_signal("ready_for_movement"):
		entity.emit_signal("ready_for_movement")

func _on_gather_resource(resource):
	if not state or state.current_state != SkeletonState.State.GATHERING or is_gathering_anim:
		return
	print("amin_on_gather_resource")
	is_gathering_anim = true
	if state:
		state.set_state(SkeletonState.State.GATHERING)
	play_anim("1H_Melee_Attack_Chop")
	await animation_player.animation_finished
	is_gathering_anim = false
	emit_signal("gather_animation_finished", resource)
	if resource and resource.is_inside_tree():  # Убеждаемся, что ресурс еще существует
		var state_component = resource.components["state"] as ResourceState
		if state_component:
			state_component.take_damage(1)  # Нанесение урона (1 HP)
	if state:
		state.set_state(SkeletonState.State.IDLE)

func process(delta: float):
	if can_move and not is_gathering_anim:
		update_animation()

func update_animation():
	if is_gathering_anim or not state or not state.is_ready_for_movement():
		return
	var velocity_length = entity.velocity.length()
	if velocity_length > 0.01:
		if state and state.current_state != SkeletonState.State.MOVING:
			state.set_state(SkeletonState.State.MOVING)
		play_anim("Running_A")
	else:
		if state and state.current_state != SkeletonState.State.IDLE:
			state.set_state(SkeletonState.State.IDLE)
		play_anim("Idle")

func play_anim(name_anim: String):
	if not animation_player:
		return
		
	if last_animation != name_anim or not animation_player.is_playing():
		animation_player.play(name_anim)
		last_animation = name_anim

func _on_rise_completed():
	_start_death_pose()

func _on_ready_for_movement():
	can_move = true

func _on_state_changed(new_state: int):
	pass
