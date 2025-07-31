# base_component.gd
class_name BaseComponentComposition extends Node

signal component_initialized
signal component_enabled
signal component_disabled

var entity: Unit
var is_active: bool = true

func init(_entity: Unit) -> void:
	entity = _entity
	component_initialized.emit()
	#_setup()

func enable() -> void:
	is_active = true
	component_enabled.emit()

func disable() -> void:
	is_active = false
	component_disabled.emit()

func _setup() -> void:
	pass
	
func _input(event: InputEvent) -> void:
	pass
	
func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass
