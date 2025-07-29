extends BaseComponent
class_name SkeletonGathering

var current_resource: Gatherable = null
@export var gather_radius: float = 12.0

var is_gathering: bool = false
var is_waiting_cooldown: bool = false
var search_cooldown: float = 0.0
const SEARCH_INTERVAL: float = 1.0

var gather_cooldown: float = 0.0
const GATHER_COOLDOWN_TIME: float = 0.5

var assigned_slot_offset: Vector3 = Vector3.ZERO

var navigation: SkeletonNavigation
var state: SkeletonState

func _setup() -> void:
	navigation = entity.get_component(SkeletonNavigation)
	state = entity.get_component(SkeletonState)

func process(delta: float) -> void:
	if current_resource and is_instance_valid(current_resource):
		var res_state = current_resource.components["state"] as ResourceState
		if res_state and not res_state.is_depleted:
			_handle_resource(delta)
		else:
			_clear_resource()
			_handle_search(delta)
	else:
		_clear_resource()
		_handle_search(delta)

func _handle_resource(delta: float) -> void:
	if is_waiting_cooldown:
		gather_cooldown -= delta
		if gather_cooldown <= 0:
			is_waiting_cooldown = false
		return

	var target_pos = current_resource.global_position + assigned_slot_offset
	navigation.set_target_position(target_pos)

	if navigation.is_navigation_finished():
		navigation.direction = Vector3.ZERO
		if gather_cooldown <= 0 and not is_gathering:
			is_gathering = true
			if state:
				state.set_state(SkeletonState.State.GATHERING)
			entity.emit_signal("gather_resource", current_resource)
	else:
		entity.get_component(SkeletonInput).direction = navigation.update_direction()

func _handle_search(delta: float) -> void:
	search_cooldown -= delta
	if search_cooldown <= 0:
		current_resource = find_nearest_resource()
		if current_resource and is_instance_valid(current_resource):
			var res_state = current_resource.components["state"] as ResourceState
			if res_state:
				var slot = res_state.add_gatherer(entity)
				if slot != null:
					assigned_slot_offset = slot
				else:
					_clear_resource()
			else:
				_clear_resource()
		search_cooldown = SEARCH_INTERVAL

func _clear_resource():
	if current_resource and is_instance_valid(current_resource):
		var res_state = current_resource.components["state"] as ResourceState
		if res_state:
			res_state.remove_gatherer(entity)
	current_resource = null
	assigned_slot_offset = Vector3.ZERO

func find_nearest_resource() -> Gatherable:
	var nearest: Gatherable = null
	var nearest_dist = gather_radius
	for node in get_all_gatherables():
		if node is Gatherable:
			var res_state = node.components["state"] as ResourceState
			if res_state and not res_state.is_depleted and res_state.can_add_gatherer() and res_state.is_marked:
				var dist = entity.global_position.distance_to(node.global_transform.origin)
				if dist < nearest_dist:
					nearest = node
					nearest_dist = dist
	return nearest

func get_all_gatherables() -> Array:
	return get_tree().get_nodes_in_group("Gatherables")

func reset_gathering() -> void:
	is_gathering = false
	is_waiting_cooldown = true
	#gather_cooldown = GATHER_COOLDOWN_TIME
