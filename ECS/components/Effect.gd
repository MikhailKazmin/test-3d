extends Resource
class_name EffectComponent

@export var effect_type: String = ""
@export var center: Vector3
@export var radius: float = 5.0
@export var duration: float = 3.0  # сколько действует эффект
@export var elapsed: float = 0.0   # сколько уже прошло
 
func reset() -> void:
	effect_type = ""
	center = Vector3.ZERO
	radius = 5.0
	duration = 3.0
	elapsed = 0.0
