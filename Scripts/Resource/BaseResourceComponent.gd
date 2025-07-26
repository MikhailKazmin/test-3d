extends Node
class_name BaseResourceComponent

var entity: Gatherable = null
var is_active: bool = true

func init(_entity: Gatherable) -> void:
	entity = _entity
