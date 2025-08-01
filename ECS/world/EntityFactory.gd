# world/EntityFactory.gd
extends Node
class_name EntityFactory

var ecs_manager: ECSManager
var component_pool: ComponentPool
var event_bus: EventBus
var async_event_queue: AsyncEventQueue
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
	add_components_to_entity(skeleton)
	
	var nav:NavigationComponent = skeleton.get_component(ComponentType.get_mask(ComponentType.Name.Navigation))
	nav.target_position = position
	# Инстанцируем и добавляем визуал в корневую сцену
	var skeleton_scene = preload(SKELETON_PREFAB_PATH).instantiate() as CharacterBody3D
	if not skeleton_scene:
		printerr("Failed to instantiate skeleton prefab at %s" % SKELETON_PREFAB_PATH)
		return skeleton
	ecs_manager.add_child(skeleton_scene)  # Добавляем в World
	skeleton_scene.global_position = position
	
	await get_tree().create_timer(0.3).timeout
	
	# Настраиваем CharacterBody3DComponent
	var body_comp = skeleton.get_component(ComponentType.get_mask(ComponentType.Name.CharacterBody3D))
	if body_comp:
		body_comp.character_body_3d = skeleton_scene
		body_comp.nav_agent = skeleton_scene.get_node("NavigationAgent3D")
		body_comp.animation_player = skeleton_scene.get_node("AnimationPlayer")
		body_comp.rig = skeleton_scene.get_node("Rig")
		body_comp.label_3d = skeleton_scene.get_node("Label3D")
		body_comp.mark = skeleton_scene.get_node("Mark")
		# Активируем узлы
		for node in [ body_comp.rig, body_comp.label_3d, body_comp.mark]:
			if node:
				node.set_process(true)
				node.set_physics_process(true)
				if node in [body_comp.rig,\
				]:
				 #body_comp.label_3d]:
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
	
func create_resurrect_effect(center: Vector3, radius: float, duration: float = 3.0) -> Entity:
	var effect_entity = ecs_manager.create_entity()
	var effect_comp = component_pool.get_component(ComponentType.Name.Effect)
	effect_comp.effect_type = "resurrect"
	effect_comp.center = center
	effect_comp.radius = radius
	effect_comp.duration = duration
	effect_comp.elapsed = 0.0
	effect_entity.add_component(effect_comp, ComponentType.get_mask(ComponentType.Name.Effect))
	return effect_entity

func create_resource(position: Vector3, resource_type: String, amount: int, mark: Node3D) -> Entity:
	var entity = ecs_manager.create_entity()

	# Позиция
	var pos_comp = component_pool.get_component(ComponentType.Name.Position)
	pos_comp.position = position
	entity.add_component(pos_comp, ComponentType.get_mask(ComponentType.Name.Position))

	# Собираемый ресурс
	var gatherable_comp = component_pool.get_component(ComponentType.Name.Gatherable)
	gatherable_comp.resource_type = resource_type
	gatherable_comp.amount = amount
	entity.add_component(gatherable_comp, ComponentType.get_mask(ComponentType.Name.Gatherable))

	# Состояние ресурса
	var state_comp = component_pool.get_component(ComponentType.Name.ResourceState)
	state_comp.is_depleted = false
	state_comp.is_marked = false
	state_comp.mark = mark
	entity.add_component(state_comp, ComponentType.get_mask(ComponentType.Name.ResourceState))

	# Маркер
	var mark_comp = component_pool.get_component(ComponentType.Name.Mark)
	mark_comp.mark = mark
	entity.add_component(mark_comp, ComponentType.get_mask(ComponentType.Name.Mark))

	return entity
	
