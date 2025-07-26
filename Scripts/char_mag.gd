extends CharacterBody3D

# --- Экспортируемые переменные ---
@export var projectile_scene: PackedScene
@export var mouse_sensitivity := 0.002
@export var SPEED := 5.0
@export var GRAVITY := 9.8
@export var JUMP_VELOCITY := 4.5
@export var camera_clamp_min := deg_to_rad(-50)
@export var camera_clamp_max := deg_to_rad(60)

# --- Ноды ---
@onready var rig: Node3D = $Rig
@onready var camera_rig: Node3D = $CameraRig
@onready var camera_pivot: Node3D = $CameraRig/CameraPivot
@onready var camera: Camera3D = $CameraRig/CameraPivot/Camera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var crosshair: TextureRect = $"../CanvasLayer/HUD/Crosshair"
@onready var hand_marker: Node3D = $Rig/HandMarker

# --- Переменные состояния ---
var rotation_x := 0.0
var rotation_y := 0.0
var mouse_locked := true
var is_attacking := false
var is_jumping := false
var is_aiming := false
var move_direction := Vector3.ZERO
var last_animation := ""

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crosshair.visible = false

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		toggle_mouse_lock()
	
	if event.is_action_pressed("attack") and can_attack():
		play_attack()
	
	if event.is_action_pressed("jump") and can_jump():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

func _unhandled_input(event):
	if event is InputEventMouseMotion and mouse_locked:
		handle_mouse_movement(event)

func _process(_delta):
	update_camera()
	update_movement_direction()
	
	is_aiming = Input.is_action_pressed("aim")
	crosshair.visible = is_aiming
	
	if not is_attacking:
		update_rotation_based_on_movement()

func _physics_process(delta):
	apply_movement(delta)
	apply_gravity(delta)
	move_and_slide()
	
	if not is_attacking:
		update_animation()

# --- Вспомогательные методы ---
func toggle_mouse_lock():
	mouse_locked = !mouse_locked
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if mouse_locked else Input.MOUSE_MODE_VISIBLE)

func can_attack() -> bool:
	return not is_attacking and is_on_floor()

func can_jump() -> bool:
	return is_on_floor() and not is_attacking

func handle_mouse_movement(event: InputEventMouseMotion):
	rotation_y -= event.relative.x * mouse_sensitivity
	rotation_x = clamp(rotation_x - event.relative.y * mouse_sensitivity, 
					  camera_clamp_min, camera_clamp_max)

func update_camera():
	camera_rig.global_position = global_position
	camera_rig.rotation.y = rotation_y
	camera_pivot.rotation.x = rotation_x
	camera.position = Vector3(0, 2, 6)

func update_movement_direction():
	if is_attacking:
		move_direction = Vector3.ZERO
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	var cam_forward = camera.global_transform.basis.z
	var cam_right = camera.global_transform.basis.x
	
	move_direction = (-cam_forward * input_dir.y + cam_right * input_dir.x).normalized()
	move_direction.y = 0

func update_rotation_based_on_movement():
	var look_dir = -camera.global_transform.basis.z
	if is_aiming or move_direction.length() > 0.1:
		rig.rotation.y = atan2(look_dir.x, look_dir.z)

func apply_movement(delta: float):
	if move_direction.length() > 0.1:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif not is_jumping:
		velocity.y = 0

func update_animation():
	if not is_on_floor():
		play_air_animation()
		return
	
	if move_direction.length() < 0.1:
		play_anim("Idle")
		return
	
	play_movement_animation()

func play_air_animation():
	if velocity.y > 0:
		play_anim("Jump_Start")
	else:
		play_anim("Jump_Land")

func play_movement_animation():
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
	var dir = move_direction.normalized()
	
	var forward_dot = forward.dot(dir)
	var right_dot = right.dot(dir)
	
	if forward_dot > 0.7:
		play_anim("Running_A")
	elif forward_dot < -0.7:
		play_anim("Walking_Backwards")
	elif right_dot > 0.5:
		play_anim("Running_Strafe_Right")
	elif right_dot < -0.5:
		play_anim("Running_Strafe_Left")
	else:
		play_anim("Running_A")

func play_attack():
	is_attacking = true
	velocity = Vector3.ZERO
	play_anim("Spellcast_Shoot")
	
	await animation_player.animation_finished
	spawn_projectile()
	is_attacking = false

func spawn_projectile():
	if not projectile_scene:
		push_warning("Нет сцены снаряда!")
		return
	
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	projectile.global_transform.origin = hand_marker.global_transform.origin
	
	var crosshair_pos: Vector2 = crosshair.get_screen_position() + crosshair.size / 2
	var from = camera.project_ray_origin(crosshair_pos)
	var to = from + camera.project_ray_normal(crosshair_pos) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	var target_point: Vector3 = result.position if result else to
	
	var direction = (target_point - hand_marker.global_transform.origin).normalized()
	
	if projectile.has_method("launch"):
		projectile.launch(direction)
	else:
		push_warning("Префаб не имеет метода launch()!")

func play_anim(anim_name: String):
	if last_animation != anim_name or not animation_player.is_playing():
		animation_player.play(anim_name)
		last_animation = anim_name
