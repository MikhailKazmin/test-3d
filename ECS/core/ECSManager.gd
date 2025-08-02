# core/ECSManager.gd
extends Node
class_name ECSManager

var entities: Dictionary = {}
var archetypes: Dictionary = {}
var last_entity_id: int = 0

func create_entity() -> Entity:
	var entity = Entity.new(last_entity_id, self)
	last_entity_id += 1
	entities[entity.id] = entity
	return entity

func remove_entity(entity: Entity) -> void:
	entities.erase(entity)
	for arr in archetypes.values():
		arr.erase(entity)

func _on_component_changed(entity: Entity) -> void:
	for arr in archetypes.values():
		arr.erase(entity)
	var mask = entity.component_mask
	if not archetypes.has(mask):
		archetypes[mask] = []
	archetypes[mask].append(entity)

func filter_entities(required_mask: int) -> Array:
	var filtered: Array = []
	for mask in archetypes.keys():
		if (mask & required_mask) == required_mask:
			filtered.append_array(archetypes[mask])
	
	return filtered

func get_entity_by_id(entity_id: int) -> Entity:
	return entities.get(entity_id, null)
