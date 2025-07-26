# EnemyAgent.gd
extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rig: Node3D = $Rig

const SPEED := 5.0
var last_animation := ""

func _ready():
	set_random_target()

func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		set_random_target()
		return

	var next_path_pos = nav_agent.get_next_path_position()
	var direction = (next_path_pos - global_position).normalized()
	direction.y = 0

	velocity = direction * SPEED
	move_and_slide()

	# Поворот модели в сторону движения (исправлено направление)
	if direction.length() > 0.01:
		rig.rotation.y = atan2(direction.x, direction.z)

	update_animation(direction)

func update_animation(direction: Vector3):
	if direction.length() < 0.01:
		play_anim("Idle")
	else:
		play_anim("Running_A")

func play_anim(name_anim: String):
	if last_animation != name_anim or not animation_player.is_playing():
		animation_player.play(name_anim)
		last_animation = name_anim

func set_random_target():
	var new_pos = global_position + Vector3(randf() * 20 - 10, 0, randf() * 20 - 10)
	nav_agent.set_target_position(new_pos)
