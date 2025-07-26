extends Node3D
class_name Gatherable

@export var resource_id: String = "stone"
@export var component_parent: Node

var components: Dictionary = {}

func _ready():
	components = {
		"state": $Components/State,
		"interaction": $Components/Interaction
	}
	for component in components.values():
		if component is BaseResourceComponent:
			component.init(self)
	for component in components.values():
		if component is BaseResourceComponent:
			if component.has_method("_setup"):
				component._setup()

func _process(delta: float):
	if not components["state"].is_depleted:
		# Обновляем визуальную реакцию, если есть
		pass
