extends CharacterBody3D
class_name Entity

@export var component_parent: Node
@onready var components: Dictionary = {}

func _ready() -> void: 
	for component in components.values():
		if component is BaseComponent:
			component.init(self)
	for component in components.values():
		if component is BaseComponent:
			component._setup()

func _process(delta: float) -> void:
	for component in components.values():
		if component is BaseComponent and component.is_active:
			component.process(delta)

func _physics_process(delta: float) -> void:
	for component in components.values():
		if component is BaseComponent and component.is_active:
			component.physics_process(delta)

func _input(event: InputEvent) -> void:
	for component in components.values():
		if component is BaseComponent and component.is_active:
			component._input(event)

func get_component(component_class: GDScript) -> Node:
	if not component_parent:
		push_error("ComponentParent not set!")
		return null
	for child in component_parent.get_children():
		if child.get_script() == component_class:
			return child
	push_error("Компонент " + component_class.name + " не найден!")
	return null
