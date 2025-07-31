# components/MoveComponent.gd
extends BaseComponent
class_name MoveComponent

var speed: float = 2.0
var can_move: bool = false
var velocity: Vector3 = Vector3.ZERO

func reset():
	speed = 2.0
	can_move = false
	velocity = Vector3.ZERO
