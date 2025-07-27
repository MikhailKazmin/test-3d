extends BaseAttack
class_name PlayerAttack


@onready var crosshair: TextureRect = $"../../../CanvasLayer/HUD/Crosshair"


var input: PlayerInput
var camera: PlayerCamera
func _setup():
	input = entity.get_component(PlayerInput)
	camera = entity.get_component(PlayerCamera)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			var hit = _get_crosshair_position()
			if hit: entity.caster.start_cast(hit)
		else:
			entity.caster.confirm_cast()

func process(_delta: float) -> void:
	if not is_active:
		return
	if input.aim_pressed:
		crosshair.visible = true
		var hit = _get_crosshair_position()
		if hit: entity.caster.update_radius(hit)
	else:
		crosshair.visible = false

func _get_crosshair_position() -> Vector3:
	var crosshair_screen_pos = crosshair.get_global_transform().origin + crosshair.size / 2
	var from = camera.camera.project_ray_origin(crosshair_screen_pos)
	var to = from + camera.camera.project_ray_normal(crosshair_screen_pos) * 1000.0

	var plane_y = get_floor_y()
	var result = ray_intersect_plane(from, to, plane_y)
	return result
	
func ray_intersect_plane(from: Vector3, to: Vector3, plane_y: float) -> Vector3:
	var dir = to - from
	if abs(dir.y) < 0.0001:
		return Vector3.ZERO
	var t = (plane_y - from.y) / dir.y
	if t < 0 or t > 1:
		return Vector3.ZERO
	return from + dir * t

func get_floor_y() -> float:
	return 0.0
