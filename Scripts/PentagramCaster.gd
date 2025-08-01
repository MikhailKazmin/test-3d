extends Node3D
class_name PentagramCaster

@export var world: World
@export var pentagram_wheel: PentagramWheel  # Ссылка на колесо

var center: Vector3
var radius: float = 5.0

func show_wheel():
	pentagram_wheel.set_effects(world.get_available_effects())
	pentagram_wheel.center_on_screen()
	pentagram_wheel.visible = true

func _ready():
	pentagram_wheel.connect("effect_selected", Callable(self, "_on_effect_selected"))

func _on_effect_selected(effect_type: String, data):
	# Можно сюда добавить проверку на тип эффекта, разные ECS-создания:
	match effect_type:
		"resurrect":
			world.entity_factory.create_resurrect_effect(center, radius)
		"formation":
			world.formation_effect_system.apply(center, radius)
		"gather_mark":
			world.gather_mark_effect_system.apply(center, radius)
		"skeleton_mark":
			world.skeleton_mark_effect_system.apply(center, radius)
		_:
			push_warning("Unknown effect type: %s" % effect_type)
