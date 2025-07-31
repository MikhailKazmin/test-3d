extends BaseComponent
class_name InputComponent

var can_control: bool = false
var direction: Vector3 = Vector3.ZERO

func reset():
	can_control = false
	direction = Vector3.ZERO
