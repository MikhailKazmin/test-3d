extends Resource
class_name PentagramEffect

@export var name: String
@export var texture: Texture2D
@export var texture_wheel: Texture2D
@export var effect_script: Script  # Скрипт с логикой применения
@export var cast_duration: float = 3.0

func apply(center: Vector3, radius: float, caller: Node) -> void:
	if not effect_script:
		push_warning("Effect script not assigned")
		return

	var effect_instance = effect_script.new()
	if effect_instance.has_method("apply"):
		effect_instance.apply(center, radius, caller)
	else:
		push_error("Effect script lacks 'apply' method")
 
