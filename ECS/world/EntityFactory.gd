# world/EntityFactory.gd
extends Node
class_name EntityFactory

var ecs_manager: ECSManager
var component_pool: ComponentPool
var event_bus: EventBus
const SKELETON_PREFAB_PATH := "res://ECS/skeleton.tscn"
var skeleton:Entity

func _init(manager: ECSManager, pool: ComponentPool, bus: EventBus):
	ecs_manager = manager
	component_pool = pool
	event_bus = bus

func add_components_to_entity(entity: Entity):
	# Добавляем компоненты
	entity.add_component(component_pool.get_component(ComponentType.Name.State), ComponentType.get_mask(ComponentType.Name.State))
	entity.add_component(component_pool.get_component(ComponentType.Name.Navigation), ComponentType.get_mask(ComponentType.Name.Navigation))
	entity.add_component(component_pool.get_component(ComponentType.Name.Gathering), ComponentType.get_mask(ComponentType.Name.Gathering))
	entity.add_component(component_pool.get_component(ComponentType.Name.RandomMovement), ComponentType.get_mask(ComponentType.Name.RandomMovement))
	entity.add_component(component_pool.get_component(ComponentType.Name.Formation), ComponentType.get_mask(ComponentType.Name.Formation))
	entity.add_component(component_pool.get_component(ComponentType.Name.Move), ComponentType.get_mask(ComponentType.Name.Move))
	entity.add_component(component_pool.get_component(ComponentType.Name.Animation), ComponentType.get_mask(ComponentType.Name.Animation))
	entity.add_component(component_pool.get_component(ComponentType.Name.Position), ComponentType.get_mask(ComponentType.Name.Position))
	entity.add_component(component_pool.get_component(ComponentType.Name.Rotate), ComponentType.get_mask(ComponentType.Name.Rotate))
	entity.add_component(component_pool.get_component(ComponentType.Name.CharacterBody3D), ComponentType.get_mask(ComponentType.Name.CharacterBody3D))

func create_skeleton(position: Vector3) -> Entity:
	skeleton = ecs_manager.create_entity()
	#skeleton.name = "Skeleton_" + var_to_str(skeleton.id) 
	add_components_to_entity(skeleton)
	
	var nav:NavigationComponent = skeleton.get_component(ComponentType.get_mask(ComponentType.Name.Navigation))
	nav.target_position = position
	# Инстанцируем и добавляем визуал в корневую сцену
	var skeleton_scene = preload(SKELETON_PREFAB_PATH).instantiate() as CharacterBody3D
	if not skeleton_scene:
		printerr("Failed to instantiate skeleton prefab at %s" % SKELETON_PREFAB_PATH)
		return skeleton
	ecs_manager.get_parent().summons.add_child(skeleton_scene)  # Добавляем в World
	skeleton_scene.global_position = position
	
	#await get_tree().create_timer(0.3).timeout
	
	# Настраиваем CharacterBody3DComponent
	var state_comp = skeleton.get_component(ComponentType.get_mask(ComponentType.Name.State))
	var body_comp = skeleton.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
	if body_comp and state_comp:
		body_comp.character_body_3d = skeleton_scene
		body_comp.nav_agent = skeleton_scene.get_node("NavigationAgent3D")
		body_comp.animation_player = skeleton_scene.get_node("AnimationPlayer")
		body_comp.rig = skeleton_scene.get_node("Rig")
		state_comp.label_3d = skeleton_scene.get_node("Label3D")
		state_comp.mark = skeleton_scene.get_node("Mark")
		# Активируем узлы
		for node in [ body_comp.rig, state_comp.label_3d, state_comp.mark]:
			if node:
				node.set_process(true)
				node.set_physics_process(true)
				if node in [body_comp.rig,\
				]:
				 #state_comp.label_3d]:
					node.visible = true
	else:
		printerr("CharacterBody3D component not found for entity #%d" % skeleton.id)

	var pos_comp = skeleton.get_component(ComponentType.get_mask(ComponentType.Name.Position))
	if pos_comp:
		pos_comp.position = position
	else:
		printerr("Position component not found for entity #%d" % skeleton.id)
	
	event_bus.emit(EventBus.Name.RiseStarted, [skeleton.id])
	
	return skeleton
	

func init_all_corpses_in_ecs():
	var corpses = get_tree().get_nodes_in_group("Corpses")
	for corpse in corpses:
		var entity = ecs_manager.create_entity()
		#entity.name = corpse.name
		entity.add_component(component_pool.get_component(ComponentType.Name.State), ComponentType.get_mask(ComponentType.Name.State))
		entity.add_component(component_pool.get_component(ComponentType.Name.CharacterBody3D), ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
		entity.add_component(component_pool.get_component(ComponentType.Name.Animation), ComponentType.get_mask(ComponentType.Name.Animation))
		entity.add_component(component_pool.get_component(ComponentType.Name.Position), ComponentType.get_mask(ComponentType.Name.Position))

		var body_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
		if body_comp:
			body_comp.character_body_3d = corpse
			body_comp.animation_player = corpse.get_node("AnimationPlayer")
			body_comp.rig = corpse.get_node("Rig")

		var state_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.State))
		if state_comp:
			event_bus.emit(EventBus.Name.SetState, [entity.id, StateComponent.State.DEATH_POSE])
		var pos_comp: PositionComponent = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		if pos_comp:
			pos_comp.position = corpse.global_position


func init_all_gatherables_in_ecs():
	var gatherables = get_tree().get_nodes_in_group("Gatherables")
	for gatherable in gatherables:
		var entity = ecs_manager.create_entity()

		# Добавляем компоненты ресурса
		entity.add_component(component_pool.get_component(ComponentType.Name.Gatherable), ComponentType.get_mask(ComponentType.Name.Gatherable))
		entity.add_component(component_pool.get_component(ComponentType.Name.Position), ComponentType.get_mask(ComponentType.Name.Position))

		# Заполняем поля GatherableComponent (состояние и визуал ресурса)
		var gatherable_comp = entity.get_component(ComponentType.get_mask(ComponentType.Name.Gatherable))
		if gatherable_comp:
			gatherable_comp.mark = gatherable.get_node_or_null("Mark")
			if gatherable_comp.mark:
				gatherable_comp.mark.visible = false
			gatherable_comp.is_depleted = false
			gatherable_comp.is_marked = false

		# Позиция ресурса
		var pos_comp: PositionComponent = entity.get_component(ComponentType.get_mask(ComponentType.Name.Position))
		if pos_comp:
			pos_comp.position = gatherable.global_position
