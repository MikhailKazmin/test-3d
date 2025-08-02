extends Entity
class_name Corpse
 
@export var new_prefab: PackedScene  # Присвойте префаб в инспекторе


func _ready() -> void:
	components = {
		"animation": $Components/PlayerAnimation
	}
	
func get_new_prefab() -> PackedScene:
	return new_prefab
