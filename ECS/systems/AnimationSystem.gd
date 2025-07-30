# systems/AnimationSystem.gd
extends Node
class_name AnimationSystem

var ecs_manager: ECSManager
var event_bus: EventBus
var async_queue: AsyncEventQueue
var required_mask: int

func _init(manager: ECSManager, bus: EventBus, async_q: AsyncEventQueue):
	ecs_manager = manager
	event_bus = bus
	async_queue = async_q
	required_mask = ComponentType.get_mask("Animation") | ComponentType.get_mask("State") | ComponentType.get_mask("Move") | ComponentType.get_mask("CharacterBody3D") | ComponentType.get_mask("Position")
	event_bus.subscribe("rise_started", Callable(self, "_on_rise_started"))
	event_bus.subscribe("rise_completed", Callable(self, "_on_rise_completed"))
	event_bus.subscribe("gather_resource", Callable(self, "_on_gather_resource"))
	event_bus.subscribe("state_changed", Callable(self, "_on_state_changed"))

func _process(delta):
	var entities = ecs_manager.filter_entities(required_mask)
	for entity in entities:
		var anim_comp = entity.get_component(ComponentType.get_mask("Animation"))
		var state_comp = entity.get_component(ComponentType.get_mask("State"))
		var move_comp = entity.get_component(ComponentType.get_mask("Move"))
		var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
		if move_comp.can_move and not anim_comp.is_gathering_anim:
			var velocity_length = move_comp.velocity.length()
			if velocity_length > 0.01:
				if state_comp.current_state != StateComponent.State.MOVING:
					event_bus.emit("set_state", [entity.id, StateComponent.State.MOVING])
				_play_anim(body_comp.animation_player, anim_comp, "Running_A")
			else:
				if state_comp.current_state != StateComponent.State.IDLE:
					event_bus.emit("set_state", [entity.id, StateComponent.State.IDLE])
				_play_anim(body_comp.animation_player, anim_comp, "Idle")

func _play_anim(anim_player: AnimationPlayer, anim_comp: AnimationComponent, name_anim: String):
	print("AnimationSystem._play_anim = ", name_anim)
	if anim_comp.last_animation != name_anim or not anim_player.is_playing():
		anim_player.play(name_anim)
		anim_comp.last_animation = name_anim

func _on_rise_started(args: Array):
	print("AnimationSystem._on_rise_started")
	var entity_id = args[0]
	async_queue.add_async(Callable(self, "_rise_tween"), 0.0, [entity_id])

func _rise_tween(entity_id: int):
	print("AnimationSystem._rise_tween")
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
	var tween = create_tween()
	tween.tween_property(body_comp.character_body_3d, "global_position:y", body_comp.character_body_3d.global_position.y + 2, 1.0)
	await tween.finished
	event_bus.emit("rise_completed", [entity_id])

func _on_rise_completed(args: Array):
	print("AnimationSystem._on_rise_completed")
	var entity_id = args[0]
	async_queue.add_async(Callable(self, "_start_death_pose"), 0.0, [entity_id])

func _start_death_pose(entity_id: int):
	event_bus.emit("set_state", [entity_id, StateComponent.State.DEATH_POSE])
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var anim_comp = entity.get_component(ComponentType.get_mask("Animation"))
	var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
	anim_comp.current_phase = "death_pose"
	_play_anim(body_comp.animation_player, anim_comp, "Death_A_Pose")
	async_queue.add_async(Callable(self, "_start_stand_up"), 2.0, [entity_id])
	print("AnimationSystem._start_death_pose")

func _start_stand_up(entity_id: int):
	print("AnimationSystem._start_stand_up")
	event_bus.emit("set_state", [entity_id, StateComponent.State.STANDING_UP])
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var anim_comp = entity.get_component(ComponentType.get_mask("Animation"))
	var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
	anim_comp.current_phase = "standing_up"
	_play_anim(body_comp.animation_player, anim_comp, "Lie_StandUp")
	await body_comp.animation_player.animation_finished
	_complete_sequence(entity_id)

func _complete_sequence(entity_id: int):
	print("AnimationSystem._complete_sequence")
	event_bus.emit("set_state", [entity_id, StateComponent.State.IDLE])
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var anim_comp = entity.get_component(ComponentType.get_mask("Animation"))
	anim_comp.current_phase = "idle"
	_play_anim(entity.get_component(ComponentType.get_mask("CharacterBody3D")).animation_player, anim_comp, "Idle")
	event_bus.emit("ready_for_movement", [entity_id])

func _on_gather_resource(args: Array):
	var entity_id = args[0]
	var resource = args[1]
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var anim_comp = entity.get_component(ComponentType.get_mask("Animation"))
	var state_comp = entity.get_component(ComponentType.get_mask("State"))
	var body_comp = entity.get_component(ComponentType.get_mask("CharacterBody3D"))
	if state_comp.current_state != StateComponent.State.GATHERING or anim_comp.is_gathering_anim:
		return
	anim_comp.is_gathering_anim = true
	_play_anim(body_comp.animation_player, anim_comp, "1H_Melee_Attack_Chop")
	await body_comp.animation_player.animation_finished
	anim_comp.is_gathering_anim = false
	event_bus.emit("gather_animation_finished", [entity_id, resource])

func _on_state_changed(args: Array):
	pass  # Если нужно обработать
