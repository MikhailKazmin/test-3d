# systems/BehaviorSystem.gd
extends Node
class_name BehaviorSystem

var ecs_manager: ECSManager
var async_queue: AsyncEventQueue
var event_bus: EventBus
var required_mask: int


func _init(manager: ECSManager, async_q: AsyncEventQueue, bus: EventBus):
	ecs_manager = manager
	async_queue = async_q
	event_bus = bus
	required_mask = ComponentType.get_mask("State") | ComponentType.get_mask("Formation") | ComponentType.get_mask("Gathering") | ComponentType.get_mask("RandomMovement") | ComponentType.get_mask("Navigation") | ComponentType.get_mask("Position")

	call_deferred("_sub_events")

func _sub_events() -> void:
	event_bus.subscribe("ready_for_movement", Callable(self, "_on_ready_for_movement"))
	event_bus.subscribe("gather_animation_finished", Callable(self, "_on_gather_animation_finished"))	
	
	
func _physics_process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	
	for entity in entities:
		var state_comp = entity.get_component(ComponentType.get_mask("State"))
		if not _is_ready_for_movement(state_comp):
			continue
		var form_comp = entity.get_component(ComponentType.get_mask("Formation"))
		var gath_comp = entity.get_component(ComponentType.get_mask("Gathering"))
		var rand_comp = entity.get_component(ComponentType.get_mask("RandomMovement"))
		var nav_comp = entity.get_component(ComponentType.get_mask("Navigation"))
		var pos_comp = entity.get_component(ComponentType.get_mask("Position"))
		if form_comp.formation_target != Vector3.ZERO:
			nav_comp.target_position = form_comp.formation_target
			if nav_comp.target_position.distance_to(pos_comp.position) < 0.1:
				form_comp.formation_target = Vector3.ZERO
				event_bus.emit("set_state", [entity.id, StateComponent.State.IDLE])
		elif gath_comp.current_resource and is_instance_valid(gath_comp.current_resource):
			nav_comp.target_position = gath_comp.current_resource.global_position + gath_comp.assigned_slot_offset
		else:
			_handle_search(gath_comp, delta, entity)
			_handle_random(rand_comp, nav_comp, pos_comp, delta)

func _is_ready_for_movement(state_comp: StateComponent) -> bool:
	return state_comp.current_state != StateComponent.State.GATHERING

func _handle_search(gath_comp: GatheringComponent, delta: float, entity: Entity):
	gath_comp.search_cooldown -= delta
	if gath_comp.search_cooldown <= 0:
		gath_comp.current_resource = _find_nearest_resource(entity, gath_comp)
		if gath_comp.current_resource:
			var res_state = gath_comp.current_resource.get("state")  # Предполагаем ResourceState component
			if res_state and res_state.can_add_gatherer():
				gath_comp.assigned_slot_offset = res_state.add_gatherer(entity)
			else:
				gath_comp.current_resource = null
				gath_comp.assigned_slot_offset = Vector3.ZERO
		gath_comp.search_cooldown = gath_comp.SEARCH_INTERVAL

func _find_nearest_resource(entity: Entity, gath_comp: GatheringComponent) -> Node:
	var nearest: Node = null
	var nearest_dist = gath_comp.gather_radius
	var pos_comp = entity.get_component(ComponentType.get_mask("Position"))
	var gatherables = get_tree().get_nodes_in_group("Gatherables")
	for node in gatherables:
		if node is Node:  # Gatherable
			var res_state = node.get("state")
			if res_state and not res_state.is_depleted and res_state.can_add_gatherer() and res_state.is_marked:
				var dist = pos_comp.position.distance_to(node.global_position)
				if dist < nearest_dist:
					nearest = node
					nearest_dist = dist
	return nearest

func _handle_random(rand_comp: RandomMovementComponent, nav_comp: NavigationComponent, pos_comp: PositionComponent, delta: float):
	if nav_comp.target_position.distance_to(pos_comp.position) < 0.1:
		_set_random_target(rand_comp, pos_comp)
	# Direction обновляется в NavigationSystem

func _set_random_target(rand_comp: RandomMovementComponent, pos_comp: PositionComponent):
	var min_distance = 5.0
	var new_pos: Vector3
	while true:
		new_pos = pos_comp.position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
		if new_pos.distance_to(pos_comp.position) >= min_distance:
			break
	rand_comp.last_random_target = new_pos

func _on_ready_for_movement(args: Array):
	print("BehaviorSystem._on_ready_for_movement")
	var entity_id = args[0]
	
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var move_comp = entity.get_component(ComponentType.get_mask("Move"))
	move_comp.can_move = true

func _on_gather_animation_finished(args: Array):
	var entity_id = args[0]
	var resource = args[1]
	
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var gath_comp = entity.get_component(ComponentType.get_mask("Gathering"))
	gath_comp.is_gathering = false
	gath_comp.gather_cooldown = gath_comp.GATHER_COOLDOWN_TIME
	event_bus.emit("set_state", [entity_id, StateComponent.State.IDLE])
