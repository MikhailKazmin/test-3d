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
	required_mask = ComponentType.get_mask(ComponentType.Name.Gathering) \
		| ComponentType.get_mask(ComponentType.Name.Navigation) \
		| ComponentType.get_mask(ComponentType.Name.State) \
		| ComponentType.get_mask(ComponentType.Name.Position)

	call_deferred("_sub_events")

func _sub_events() -> void:
	event_bus.subscribe(EventBus.Name.GatherResource, Callable(self, "_on_gather_resource"))

func _process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	for entity in entities:
		var gath_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Gathering))
		var nav_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Navigation))
		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
		var pos_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		if gath_comp.current_resource:
			# current_resource — это entity_id или ссылка на ресурс в ECS!
			var resource_entity = gath_comp.current_resource
			var res_pos_comp = resource_entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
			if nav_comp.target_position.distance_to(pos_comp.position) < 0.1:
				gath_comp.gather_cooldown -= delta
				if gath_comp.gather_cooldown <= 0 and not gath_comp.is_gathering:
					gath_comp.is_gathering = true
					event_bus.emit(EventBus.Name.SetState, [entity.id, StateComponent.State.GATHERING])
					event_bus.emit(EventBus.Name.GatherResource, [entity.id, resource_entity])

func _on_gather_resource(args: Array):
	var gatherer_id = args[0]
	var resource_entity = args[1]
	# Находим GatherableComponent ресурса
	var gatherable_comp = resource_entity.get_component(ComponentType.get_mask(ComponentType.Name.Gatherable))
	if gatherable_comp and not gatherable_comp.is_depleted:
		# Например, уменьшаем "здоровье" ресурса или отмечаем истощение
		# gatherable_comp.hp -= 1
		gatherable_comp.is_depleted = true  # пример
		# Можно обработать визуал, если mark есть
		if gatherable_comp.mark:
			gatherable_comp.mark.visible = false
