# systems/StateSystem.gd
extends Node
class_name StateSystem

var ecs_manager: ECSManager
var event_bus: EventBus
var required_mask: int


func _on_set_state(args: Array):
	var entity_id = args[0]
	var new_state = args[1]
	var entity = ecs_manager.get_entity_by_id(entity_id)
	if entity:
		var state_comp = entity.get_component(ComponentType.get_mask("State"))
		if state_comp.current_state != new_state:
			state_comp.current_state = new_state
			event_bus.emit("state_changed", [entity_id, new_state])

func _init(manager: ECSManager, bus: EventBus):
	ecs_manager = manager
	event_bus = bus
	required_mask = ComponentType.get_mask("State") | ComponentType.get_mask("CharacterBody3D") | ComponentType.get_mask("Position")
	call_deferred("_sub_events")

func _sub_events() -> void:
	event_bus.subscribe("set_state", Callable(self, "_on_set_state"))

func _process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	
	for entity in entities:
		var state_comp = entity.get_component(ComponentType.get_mask("State"))
		var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
		var pos_comp = entity.get_component(ComponentType.get_mask("Position"))
		if body_comp.label_3d:
			var camera = get_viewport().get_camera_3d()
			if camera:
				body_comp.label_3d.look_at(camera.global_position, Vector3.UP)
				body_comp.label_3d.rotate_y(deg_to_rad(180))
			if body_comp.label_3d.visible:
				body_comp.label_3d.text = _state_to_string(state_comp.current_state)

func _state_to_string(state: int) -> String:
	match state:
		StateComponent.State.RISING: return "RISING"
		StateComponent.State.DEATH_POSE: return "DEATH_POSE"
		StateComponent.State.STANDING_UP: return "STANDING_UP"
		StateComponent.State.IDLE: return "IDLE"
		StateComponent.State.MOVING: return "MOVING"
		StateComponent.State.ATTACKING: return "ATTACKING"
		StateComponent.State.GATHERING: return "GATHERING"
	return "UNKNOWN"
