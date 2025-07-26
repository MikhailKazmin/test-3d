extends BaseInput
class_name SkeletonInput

@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"
var can_control: bool = false
var direction: Vector3 = Vector3.ZERO
var current_resource: Gatherable = null
@export var gather_radius: float = 12.0
var is_gathering: bool = false
var state: SkeletonState
var search_cooldown: float = 0.0
const SEARCH_INTERVAL: float = 1.0  # Search every 1 second if no resource found
var assigned_slot_offset: Vector3 = Vector3.ZERO

func _setup():
	entity.connect("ready_for_movement", Callable(self, "_on_ready_for_movement"))
	var animation = entity.get_component(SkeletonAnimation)
	if animation:
		animation.connect("gather_animation_finished", Callable(self, "_on_gather_animation_finished"))
	state = entity.get_component(SkeletonState)
	if state:
		state.connect("state_changed", Callable(self, "_on_state_changed"))
	set_random_target()
	search_cooldown = 0.0

func process(delta: float):
	if not can_control or not state or not state.is_ready_for_movement():
		direction = Vector3.ZERO
		return

	if current_resource and is_instance_valid(current_resource):
		var target_pos = current_resource.global_position + assigned_slot_offset
		nav_agent.set_target_position(target_pos)
		if nav_agent.is_navigation_finished() and not is_gathering:
			is_gathering = true
			if state:
				state.set_state(SkeletonState.State.GATHERING)
			entity.emit_signal("gather_resource", current_resource)
	else:
		assigned_slot_offset = Vector3.ZERO
		search_cooldown -= delta
		if search_cooldown <= 0:
			current_resource = find_nearest_resource()
			if current_resource:
				var res_state = current_resource.components["state"] as ResourceState
				if res_state:
					var slot = res_state.add_gatherer(entity)
					if slot != null:
						assigned_slot_offset = slot
					else:
						current_resource = null
			if not current_resource:
				search_cooldown = SEARCH_INTERVAL

		if nav_agent.is_navigation_finished():
			set_random_target()
			direction = Vector3.ZERO
			return

	var next_path_pos = nav_agent.get_next_path_position()
	direction = (next_path_pos - entity.global_position).normalized()
	direction.y = 0

func find_nearest_resource() -> Gatherable:
	var nearest: Gatherable = null
	var nearest_dist = gather_radius
	for node in get_all_gatherables():
		if node is Gatherable:
			var res_state = node.components["state"] as ResourceState
			if res_state and not res_state.is_depleted and res_state.can_add_gatherer():
				var dist = entity.global_position.distance_to(node.global_transform.origin)
				if dist < nearest_dist:
					nearest = node
					nearest_dist = dist
	return nearest

func set_random_target():
	if not state or not state.is_ready_for_movement():
		return
	var new_pos = entity.global_position + Vector3(randf() * 20 - 10, 0, randf() * 20 - 10)
	nav_agent.set_target_position(new_pos)

func _on_ready_for_movement():
	can_control = true

func get_all_gatherables() -> Array:
	return get_tree().get_nodes_in_group("gatherables")

func _on_gather_animation_finished(resource):
	if resource and is_instance_valid(resource):
		var res_state = resource.components["state"] as ResourceState
		if res_state:
			res_state.remove_gatherer(entity)
	is_gathering = false
	current_resource = null
	assigned_slot_offset = Vector3.ZERO
	if state:
		state.set_state(SkeletonState.State.IDLE)

func _on_state_changed(new_state: int):
	pass
