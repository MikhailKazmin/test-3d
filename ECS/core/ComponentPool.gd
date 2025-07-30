# ecs/ComponentPool.gd
extends Node
class_name ComponentPool

var pools: Dictionary = {}  # type_name:String -> Array[Resource]

func get_component(type_name: String) -> Resource:
	if pools.has(type_name) and not pools[type_name].is_empty():
		return pools[type_name].pop_back()
	var path = "res://ECS/components/%s.gd" % type_name
	if ResourceLoader.exists(path):
		return load(path).new()
	printerr("Component %s not found" % type_name)
	return null

func release_component(type_name: String, component: Resource) -> void:
	if not pools.has(type_name):
		pools[type_name] = []
	# Очистка компонента, если нужно (reset полей)
	pools[type_name].append(component)
