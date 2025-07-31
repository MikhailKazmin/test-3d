extends BaseComponentComposition
class_name SkeletonState

signal state_changed(new_state: int)
@onready var label_3d: Label3D = $"../../Label3D"
var is_selected: bool = false
@onready var mark: Sprite3D = $"../../Mark"


enum State {
	RISING,
	DEATH_POSE, 
	STANDING_UP,
	IDLE,
	MOVING,
	ATTACKING,
	GATHERING
}

var current_state: State = State.RISING
var camera: Camera3D

func _setup():
	camera = get_viewport().get_camera_3d()
	set_process(true)

func _process(_delta):
	return
	if camera and label_3d:
		var camera_pos = camera.global_position
		label_3d.look_at(camera_pos, Vector3.UP)
		label_3d.rotate_y(deg_to_rad(180))

func set_state(new_state: State):
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)
		# Преобразуем состояние в строку для отображения
		if label_3d.visible:
			label_3d.text = _state_to_string(current_state)

func is_ready_for_movement() -> bool:
	return current_state == State.IDLE or current_state == State.MOVING

# Вспомогательная функция для преобразования состояния в строку
func _state_to_string(state: State) -> String:
	match state:
		State.RISING:
			return "RISING"
		State.DEATH_POSE:
			return "DEATH_POSE"
		State.STANDING_UP:
			return "STANDING_UP"
		State.IDLE:
			return "IDLE"
		State.MOVING:
			return "MOVING"
		State.ATTACKING:
			return "ATTACKING"
		State.GATHERING:
			return "GATHERING"
		_:
			return "UNKNOWN"
