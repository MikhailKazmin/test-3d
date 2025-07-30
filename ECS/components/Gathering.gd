extends Resource
class_name GatheringComponent

var current_resource: Node = null  # Gatherable
var gather_radius: float = 12.0
var is_gathering: bool = false
var search_cooldown: float = 0.0
var gather_cooldown: float = 0.0
var assigned_slot_offset: Vector3 = Vector3.ZERO
var SEARCH_INTERVAL: float = 1.0
