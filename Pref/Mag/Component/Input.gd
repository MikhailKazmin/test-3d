extends BaseInput
class_name PlayerInput

@export var mouse_sensitivity: float = 0.002
var mouse_locked: bool = true
var lock_toggled_this_frame: bool = false

func _setup() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if not is_active: return
	
	_handle_mouse_movement(event)
	_handle_actions(event)
	_update_aim_state()

func process(_delta: float) -> void:
	if not is_active: return
	
	_update_movement_input()

func _handle_mouse_movement(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_locked:
		look_input = event.relative
	if event.is_action_pressed("attack") and is_not_attack_and_is_floor():
		attack_pressed = true

func _handle_actions(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_not_attack_and_is_floor():
		jump_pressed = true
	if event is InputEventKey:
			if event.pressed and event.keycode == KEY_ESCAPE and not event.is_echo() and not lock_toggled_this_frame:
				_toggle_mouse_lock()
				lock_toggled_this_frame = true

func _update_movement_input() -> void:
	move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

func _update_aim_state() -> void:
	aim_pressed = Input.is_action_pressed("aim")

func _toggle_mouse_lock():
	mouse_locked = !mouse_locked
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if mouse_locked else Input.MOUSE_MODE_VISIBLE)

func is_not_attack_and_is_floor() -> bool:
	return not entity.get_component(PlayerAttack).is_attacking and entity.is_on_floor()
