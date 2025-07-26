extends BaseCamera
class_name PlayerCamera

@export var camera_clamp_min: float = deg_to_rad(-50)
@export var camera_clamp_max: float = deg_to_rad(60)

var camera_rig: Node3D
var camera_pivot: Node3D
var camera: Camera3D
var input: PlayerInput

var rotation_x: float = 0.0
var rotation_y: float = 0.0

func _setup() -> void:
	camera_rig = entity.get_node("CameraRig")
	camera_pivot = entity.get_node("CameraRig/CameraPivot")
	camera = entity.get_node("CameraRig/CameraPivot/Camera3D")
	input = entity.get_component(PlayerInput)

func process(delta: float) -> void:
	_update_camera_rotation()
	_update_camera_position()

func _update_camera_rotation() -> void:
	rotation_y -= input.look_input.x * input.mouse_sensitivity
	rotation_x = clamp(rotation_x - input.look_input.y * input.mouse_sensitivity, camera_clamp_min, camera_clamp_max)
	
	camera_rig.rotation.y = rotation_y
	camera_pivot.rotation.x = rotation_x
	input.look_input = Vector2.ZERO

func _update_camera_position() -> void:
	camera_rig.global_position = entity.global_position
