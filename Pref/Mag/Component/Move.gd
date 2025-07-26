extends BaseMove
class_name PlayerMove

@export var speed: float = 5.0
@export var acceleration: float = 10.0
@export var rotation_speed: float = 8.0
@export var jump_force: float = 4.5
@export var gravity: float = 9.8

var velocity: Vector3 = Vector3.ZERO
var input: PlayerInput
var camera: PlayerCamera
var move_direction := Vector3.ZERO

@onready var rig: Node3D = $"../../Rig"

func _setup():
	input = entity.get_component(PlayerInput)
	camera = entity.get_component(PlayerCamera)

func _process(delta):
	update_rotation_based_on_movement()

func physics_process(delta: float):
	if not is_active or not input:
		return

	_process_movement(delta)
	_process_jump()
	_apply_gravity(delta)

	entity.velocity = velocity
	entity.move_and_slide()

func _process_movement(delta: float):
	if input.attack_pressed and entity.get_component(PlayerAttack).is_attacking:
		move_direction = Vector3.ZERO
		return
	var forward = -camera.camera.global_transform.basis.z
	var right = camera.camera.global_transform.basis.x
	var input_dir = input.move_input
	var move_dir = (-forward * input_dir.y + right * input_dir.x).normalized()
	var target_velocity = Vector3(move_dir.x, 0, move_dir.z) * speed

	if target_velocity.length() > 0.1:
		velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)
		_rotate_to_direction(delta, Vector2(move_dir.x, move_dir.z))
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)

func _rotate_to_direction(delta: float, direction: Vector2):
	if direction.length() > 0.1:
		var target_angle = atan2(direction.x, direction.y)
		rig.rotation.y = lerp_angle(rig.rotation.y, target_angle, rotation_speed * delta)

func _process_jump():
	if input.jump_pressed and entity.is_on_floor():
		velocity.y = jump_force
		input.consume_jump()

func _apply_gravity(delta: float):
	if not entity.is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0:
		velocity.y = 0

func update_rotation_based_on_movement():
	var look_dir = -camera.camera.global_transform.basis.z
	if input.aim_pressed or move_direction.length() > 0.1:
		rig.rotation.y = atan2(look_dir.x, look_dir.z)
