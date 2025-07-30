# systems/FormationSystem.gd
extends Node
class_name FormationSystem

var ecs_manager: ECSManager
var required_mask: int


func _init(manager: ECSManager):
	ecs_manager = manager
	required_mask = ComponentType.get_mask("Formation") | ComponentType.get_mask("Navigation") | ComponentType.get_mask("State")

func _process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	
	for entity in entities:
		var form_comp = entity.get_component(ComponentType.get_mask("Formation"))
		var nav_comp = entity.get_component(ComponentType.get_mask("Navigation"))
		var state_comp = entity.get_component(ComponentType.get_mask("State"))
		if form_comp.formation_target != Vector3.ZERO:
			nav_comp.target_position = form_comp.formation_target
			var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
			if body_comp and body_comp.nav_agent.is_navigation_finished():
				form_comp.formation_target = Vector3.ZERO
				ecs_manager.event_bus.emit("set_state", [entity.id, StateComponent.State.IDLE])
