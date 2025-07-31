extends BaseComponent
class_name GatheringComponent

var current_resource: Node = null  # Gatherable
var gather_radius: float = 12.0
var is_gathering: bool = false
var search_cooldown: float = 0.0
var gather_cooldown: float = 0.0
var assigned_slot_offset: Vector3 = Vector3.ZERO
var SEARCH_INTERVAL: float = 1.0

func reset():
	current_resource = null  # Gatherable
	gather_radius = 12.0
	is_gathering = false
	search_cooldown = 0.0
	gather_cooldown = 0.0
	assigned_slot_offset = Vector3.ZERO
	SEARCH_INTERVAL = 1.0
