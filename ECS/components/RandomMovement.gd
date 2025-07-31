# components/RandomMovementComponent.gd
extends BaseComponent
class_name RandomMovementComponent

var last_random_target: Vector3 = Vector3.INF


func reset():
	last_random_target = Vector3.INF
