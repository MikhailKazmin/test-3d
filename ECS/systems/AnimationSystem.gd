# systems/AnimationSystem.gd
extends Node
class_name AnimationSystem

var ecs_manager: ECSManager
var event_bus: EventBus
var async_queue: AsyncEventQueue
var required_mask: int
var entities:Array

func _init(manager: ECSManager, bus: EventBus, async_q: AsyncEventQueue):
	ecs_manager = manager
	event_bus = bus
	async_queue = async_q
	required_mask = ComponentType.get_mask(ComponentType.Name.Animation) | \
		ComponentType.get_mask(ComponentType.Name.State) | \
		ComponentType.get_mask(ComponentType.Name.Move) | \
		ComponentType.get_mask(ComponentType.Name.CharacterBody3D) | \
		ComponentType.get_mask(ComponentType.Name.Position)
	#call_deferred("_sub_events")
	_sub_events()
	
	
func _sub_events() -> void:
	event_bus.subscribe(EventBus.Name.RiseStarted, Callable(self, "_on_rise_started"))
	event_bus.subscribe(EventBus.Name.RiseCompleted, Callable(self, "_on_rise_completed"))
	event_bus.subscribe(EventBus.Name.GatherResource, Callable(self, "_on_gather_resource"))
	event_bus.subscribe(EventBus.Name.StateChanged, Callable(self, "_on_state_changed"))
	
	
func _process(delta):
	entities = ecs_manager.filter_entities(required_mask)
	for entity in entities:
		var anim_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Animation))
		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
		var move_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Move))
		var body_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
		if move_comp.can_move and not anim_comp.is_gathering_anim:
			var velocity_length = move_comp.velocity.length()
			if velocity_length > 0.01:
				if state_comp.current_state != StateComponent.State.MOVING:
					event_bus.emit(EventBus.Name.SetState, [entity.id, StateComponent.State.MOVING])
				_play_anim(body_comp.animation_player, anim_comp, "Running_A")
			else:
				if state_comp.current_state != StateComponent.State.IDLE:
					event_bus.emit(EventBus.Name.SetState, [entity.id, StateComponent.State.IDLE])
				_play_anim(body_comp.animation_player, anim_comp, "Idle")

func _play_anim(anim_player: AnimationPlayer, anim_comp: AnimationComponent, name_anim: String):
	if anim_comp.last_animation != name_anim or not anim_player.is_playing():
		anim_player.play(name_anim)
		anim_comp.last_animation = name_anim

func _on_rise_started(args: Array):
	var entity_id: int = args[0]
	print("AnimationSystem._on_rise_started")
	#var entity_id = args[0]
	#_rise_tween([entity_id])
	async_queue.add_async(Callable(self, "_rise_tween"), 0.0, [entity_id])

func _rise_tween(args: Array):
	var entity_id: int = args[0]
	print("AnimationSystem._rise_tween")
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var body_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
	var tween = create_tween()
	tween.tween_property(body_comp.character_body_3d, "global_position:y", body_comp.character_body_3d.global_position.y + 2, 1.0)
	await tween.finished
	event_bus.emit(EventBus.Name.RiseCompleted, [entity_id])

func _on_rise_completed(args: Array):
	#print("AnimationSystem._on_rise_completed")
	var entity_id = args[0]
	async_queue.add_async(Callable(self, "_start_death_pose"), 0.0, [entity_id])

func _start_death_pose(args: Array):
	var entity_id: int = args[0]
	event_bus.emit(EventBus.Name.SetState, [entity_id, StateComponent.State.DEATH_POSE])
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var anim_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Animation))
	var body_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
	anim_comp.current_phase = "death_pose"
	_play_anim(body_comp.animation_player, anim_comp, "Death_A_Pose")
	async_queue.add_async(Callable(self, "_start_stand_up"), 2.0, [entity_id])
	print("AnimationSystem._start_death_pose")

func _start_stand_up(args: Array):
	var entity_id: int = args[0]
	#print("AnimationSystem._start_stand_up")
	event_bus.emit(EventBus.Name.SetState, [entity_id, StateComponent.State.STANDING_UP])
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var anim_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Animation))
	var body_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
	anim_comp.current_phase = "standing_up"
	_play_anim(body_comp.animation_player, anim_comp, "Lie_StandUp")
	await body_comp.animation_player.animation_finished
	_complete_sequence([entity_id])

func _complete_sequence(args: Array):
	var entity_id: int = args[0]
	#print("AnimationSystem._complete_sequence")
	event_bus.emit(EventBus.Name.SetState, [entity_id, StateComponent.State.IDLE])
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var anim_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Animation))
	anim_comp.current_phase = "idle"
	_play_anim(entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D)).animation_player, anim_comp, "Idle")
	event_bus.emit(EventBus.Name.ReadyForMovement, [entity_id])

func _on_gather_resource(args: Array):
	var entity_id = args[0]
	var resource = args[1]
	var entity = ecs_manager.get_entity_by_id(entity_id)
	var anim_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Animation))
	var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
	var body_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
	if state_comp.current_state != StateComponent.State.GATHERING or anim_comp.is_gathering_anim:
		return
	anim_comp.is_gathering_anim = true
	_play_anim(body_comp.animation_player, anim_comp, "1H_Melee_Attack_Chop")
	await body_comp.animation_player.animation_finished
	anim_comp.is_gathering_anim = false
	event_bus.emit(EventBus.Name.GatherAnimationFinished, [entity_id, resource])

func _on_state_changed(args: Array):
	pass  # Если нужно обработать
