extends RigidBody3D

@export var speed := 50.0

func launch(direction: Vector3):
	linear_velocity = direction * speed
	look_at(global_transform.origin + direction, Vector3.UP)
