# components/NavigationComponent.gd
extends BaseComponent
class_name NavigationComponent

var target_position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO

func reset():
	target_position = Vector3.ZERO
	direction = Vector3.ZERO
