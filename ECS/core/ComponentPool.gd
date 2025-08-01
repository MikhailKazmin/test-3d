# ecs/ComponentPool.gd
extends Node
class_name ComponentPool

var pools: Dictionary = {}  # type_name:String -> Array[Resource]

func get_component(type_name: ComponentType.Name) -> Resource:
	if pools.has(type_name) and not pools[type_name].is_empty():
		return pools[type_name].pop_back()
	var path = "res://ECS/components/%s.gd" % get_string_componentType_name(type_name) 
	if ResourceLoader.exists(path):
		return load(path).new()
	printerr("Component %s not found" % get_string_componentType_name(type_name))
	return null

func release_component(type_name: ComponentType.Name, component: Resource) -> void:
	if not pools.has(type_name):
		pools[type_name] = []
	component.reset()
	pools[type_name].append(component)


func get_string_componentType_name(Name: ComponentType.Name):
	match Name:
		ComponentType.Name.AI:
			return "AI"
		ComponentType.Name.Animation:
			return "Animation"
		ComponentType.Name.CharacterBody3D:
			return "CharacterBody3D"
		ComponentType.Name.Formation:
			return "Formation"
		ComponentType.Name.Gathering:
			return "Gathering"
		ComponentType.Name.Input:
			return "Input"
		ComponentType.Name.MeshInstance:
			return "MeshInstance"
		ComponentType.Name.Move:
			return "Move"
		ComponentType.Name.Navigation:
			return "Navigation"
		ComponentType.Name.Position:
			return "Position"
		ComponentType.Name.RandomMovement:
			return "RandomMovement"
		ComponentType.Name.Rotate:
			return "Rotate"
		ComponentType.Name.State:
			return "State"
		ComponentType.Name.Effect:
			return "Effect"
		ComponentType.Name.Corpse:
			return "Corpse"
		ComponentType.Name.Gatherable:
			return "Gatherable"
		ComponentType.Name.ResourceState:
			return "ResourceState"
		ComponentType.Name.Mark:
			return "Mark"
		_:
			return "UNKNOWN"
