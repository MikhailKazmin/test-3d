# systems/GatheringSystem.gd
extends Node
class_name GatheringSystem

var ecs_manager: ECSManager
var async_queue: AsyncEventQueue
var event_bus: EventBus
var required_mask: int

func _init(manager: ECSManager, async_q: AsyncEventQueue, bus: EventBus):
	ecs_manager = manager
	async_queue = async_q
	event_bus = bus
	required_mask = ComponentType.get_mask("Gathering") | ComponentType.get_mask("Navigation") | ComponentType.get_mask("State") | ComponentType.get_mask("Position")
	event_bus.subscribe("gather_resource", Callable(self, "_on_gather_resource"))

func _process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	
	for entity in entities:
		var gath_comp = entity.get_component(ComponentType.get_mask("Gathering"))
		var nav_comp = entity.get_component(ComponentType.get_mask("Navigation"))
		var state_comp = entity.get_component(ComponentType.get_mask("State"))
		var pos_comp = entity.get_component(ComponentType.get_mask("Position"))
		if gath_comp.current_resource and is_instance_valid(gath_comp.current_resource):
			if nav_comp.target_position.distance_to(pos_comp.position) < 0.1:
				gath_comp.gather_cooldown -= delta
				if gath_comp.gather_cooldown <= 0 and not gath_comp.is_gathering:
					gath_comp.is_gathering = true
					event_bus.emit("set_state", [entity.id, StateComponent.State.GATHERING])
					event_bus.emit("gather_resource", [entity.id, gath_comp.current_resource])

func _on_gather_resource(args: Array):
	var entity_id = args[0]
	var resource = args[1]
	
	var res_state = resource.get("state")  # ResourceState
	if res_state:
		res_state.take_damage(1)
	# Reset handled in BehaviorSystem
