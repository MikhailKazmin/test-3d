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

func create_skeleton(position: Vector3) -> Entity:
	skeleton = ecs_manager.create_entity()

	# Добавляем компоненты
	skeleton.add_component(component_pool.get_component("State"), ComponentType.get_mask("State"))
	skeleton.add_component(component_pool.get_component("Animation"), ComponentType.get_mask("Animation"))
	skeleton.add_component(component_pool.get_component("Position"), ComponentType.get_mask("Position"))
	skeleton.add_component(component_pool.get_component("CharacterBody3D"), ComponentType.get_mask("CharacterBody3D"))
	skeleton.add_component(component_pool.get_component("Move"), ComponentType.get_mask("Move"))
	var move_comp = component_pool.get_component("Move")
	move_comp.can_move = false  # Отключаем движение при создании
	#event_bus.subscribe("ready_for_movement", Callable(self, "_ready_for_movement"))
	skeleton.add_component(component_pool.get_component("Navigation"), ComponentType.get_mask("Navigation"))
	skeleton.add_component(component_pool.get_component("Gathering"), ComponentType.get_mask("Gathering"))
	skeleton.add_component(component_pool.get_component("RandomMovement"), ComponentType.get_mask("RandomMovement"))
	skeleton.add_component(component_pool.get_component("Formation"), ComponentType.get_mask("Formation"))
	skeleton.add_component(component_pool.get_component("Rotate"), ComponentType.get_mask("Rotate"))

	# Инстанцируем и добавляем визуал в корневую сцену
	var skeleton_scene = preload(SKELETON_PREFAB_PATH).instantiate() as CharacterBody3D
	if not skeleton_scene:
		printerr("Failed to instantiate skeleton prefab at %s" % SKELETON_PREFAB_PATH)
		return skeleton
	ecs_manager.add_child(skeleton_scene)  # Добавляем в World
	skeleton_scene.global_position = position
	
	await get_tree().create_timer(1).timeout
	
	# Настраиваем CharacterBody3DComponent
	var body_comp = skeleton.get_component(ComponentType.get_mask("CharacterBody3D"))
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
				if node in [body_comp.rig, body_comp.label_3d]:
					node.visible = true
	else:
		printerr("CharacterBody3D component not found for entity #%d" % skeleton.id)

	var pos_comp = skeleton.get_component(ComponentType.get_mask("Position"))
	if pos_comp:
		pos_comp.position = position
	else:
		printerr("Position component not found for entity #%d" % skeleton.id)
	
	event_bus.emit("rise_started", [skeleton.id])
	
	
	
	return skeleton
	
	
func _ready_for_movement(args: Array):
	skeleton.add_component(component_pool.get_component("Navigation"), ComponentType.get_mask("Navigation"))
	skeleton.add_component(component_pool.get_component("Gathering"), ComponentType.get_mask("Gathering"))
	skeleton.add_component(component_pool.get_component("RandomMovement"), ComponentType.get_mask("RandomMovement"))
	skeleton.add_component(component_pool.get_component("Formation"), ComponentType.get_mask("Formation"))
	skeleton.add_component(component_pool.get_component("Rotate"), ComponentType.get_mask("Rotate"))
	skeleton.add_component(component_pool.get_component("Velocity"), ComponentType.get_mask("Velocity"))

	
