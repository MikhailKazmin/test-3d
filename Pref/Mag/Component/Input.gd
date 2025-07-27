extends BaseInput
class_name PlayerInput

@export var mouse_sensitivity: float = 0.002
var mouse_locked: bool = true
var lock_toggled_this_frame: bool = false

var pentagram_wheel_visible: bool = false


func _setup() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	entity.pentagram_wheel.visible = false
	entity.pentagram_wheel.effects = entity.available_pentagram_effects  # Предполагаем, что в Player есть @export var available_pentagram_effects: Array[PentagramEffect]

func _input(event: InputEvent) -> void:
	if not is_active: return
	
	if pentagram_wheel_visible:
		# Если колесо видно, обрабатываем только события для него
		if event is InputEventKey and event.keycode == KEY_Q and not event.pressed:
			_hide_and_select_pentagram()
		elif event is InputEventMouseMotion:
			entity.pentagram_wheel.update_highlight(event.position)
		return
	
	_handle_mouse_movement(event)
	_handle_actions(event)
	_update_aim_state()
	
	# Обработка нажатия Q для показа колеса
	if event is InputEventKey and event.keycode == KEY_Q:
		if event.pressed:
			_show_pentagram_wheel()

func process(_delta: float) -> void:
	if not is_active: return
	
	_update_movement_input()

func _handle_mouse_movement(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_locked:
		look_input = event.relative

func _handle_actions(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and entity.is_on_floor():
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

func _show_pentagram_wheel() -> void:
	pentagram_wheel_visible = true
	mouse_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	entity.pentagram_wheel.visible = true
	entity.pentagram_wheel.center_on_screen()  # Метод для центрирования колеса на экране

func _hide_and_select_pentagram() -> void:
	var selected_effect = entity.pentagram_wheel.get_selected_effect()
	if selected_effect != null:
		entity.caster.current_effect = selected_effect
	entity.pentagram_wheel.visible = false
	pentagram_wheel_visible = false
	mouse_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
