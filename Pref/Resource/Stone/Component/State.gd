extends BaseResourceComponent
class_name ResourceState

@export var max_gatherers: int = 5
@export var slot_distance: float = 1.5  # Distance from resource center to slot
var current_gatherers: Dictionary = {}  # Skeleton -> slot_index
var slots: Array[Vector3] = []
var hp: int = 10
var is_depleted: bool = false

func _setup():
	for i in range(max_gatherers):
		var angle = 2 * PI * i / max_gatherers
		slots.append(Vector3(cos(angle), 0, sin(angle)) * slot_distance)

func can_add_gatherer() -> bool:
	return current_gatherers.size() < max_gatherers

func add_gatherer(skel: Skeleton) -> Vector3:
	if can_add_gatherer():
		var available_slots: Array = range(max_gatherers).filter(func(idx): return not current_gatherers.values().has(idx))
		if available_slots:
			available_slots.shuffle()  # Randomize for variety
			var slot_idx = available_slots[0]
			current_gatherers[skel] = slot_idx
			return slots[slot_idx]
	return Vector3.ZERO

func remove_gatherer(skel: Skeleton):
	current_gatherers.erase(skel)

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		is_depleted = true
		print("Ресурс исчерпан!")
		current_gatherers.clear()
		entity.queue_free()
		call_deferred("_rebake_navmesh_async")
	else:
		var tween = entity.create_tween()
		tween.tween_property(entity, "scale", Vector3(1.1, 1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)
		tween.tween_property(entity, "scale", Vector3(1.0, 1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)

func _rebake_navmesh_async():
	entity.env.update_nav.emit()

	
