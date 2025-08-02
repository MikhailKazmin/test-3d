# core/SystemRegistry.gd
extends Node
class_name SystemRegistry

var systems: Array = []

func register_system(system: Node, name_sys: String) -> void:
	systems.append(system)
	add_child(system)
	system.name = name_sys

func _process(delta):

	for sys in systems:
		if sys.has_method("_process"):
			sys._process(delta)

func _physics_process(delta):

	for sys in systems:
		if sys.has_method("_physics_process"):
			sys._physics_process(delta)
