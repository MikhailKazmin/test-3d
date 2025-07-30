# ecs/ECSLogger.gd
extends Node
class_name ECSLogger

func log_entity(entity: Entity, message: String) -> void:
	var comps = []
	for mask in entity.components.keys():
		comps.append(str(mask))
	print("Entity #%d: %s [mask=%d] [Components: %s]" % [entity.id, message, entity.component_mask, ", ".join(comps)])

func log_system(system: Node, entities: Array) -> void:
	print("System %s processing %d entities" % [system.get_class(), entities.size()])
