extends BaseComponentComposition
class_name BaseInput

var move_input: Vector2 = Vector2.ZERO
var look_input: Vector2 = Vector2.ZERO
var jump_pressed: bool = false
var attack_pressed: bool = false
var aim_pressed: bool = false

func consume_jump() -> void:
	jump_pressed = false

func consume_attack() -> void:
	attack_pressed = false
