extends Node3D
class_name World

@export var summons:Node3D
@export var enemies:Node3D
@export var corpses:Node3D
@export var gathable:Node3D

@onready var ecs_manager = preload("res://ECS/core/ECSManager.gd").new()
@onready var async_queue = preload("res://ECS/core/AsyncEventQueue.gd").new()
@onready var system_registry = preload("res://ECS/core/SystemRegistry.gd").new()
@onready var event_bus = preload("res://ECS/world/EventBus.gd").new()
@onready var component_pool = preload("res://ECS/core/ComponentPool.gd").new()
@onready var ecs_logger = preload("res://ECS/core/ECSLogger.gd").new()
@onready var entity_factory = EntityFactory.new(ecs_manager, component_pool, event_bus)

func _ready():
	register_core()
	
	register_components()
	
	register_systems()

	entity_factory.init_all_corpses_in_ecs()
	entity_factory.init_all_gatherables_in_ecs()

func register_core():
	ecs_manager.name = "ecs_manager"
	async_queue.name = "async_queue"
	system_registry.name = "system_registry"
	event_bus.name = "event_bus"
	component_pool.name = "component_pool"
	ecs_logger.name = "ecs_logger"
	entity_factory.name = "entity_factory"
	
	add_child(ecs_manager)
	add_child(async_queue)
	add_child(system_registry)
	add_child(event_bus)
	add_child(component_pool)
	add_child(ecs_logger)
	add_child(entity_factory)
	
func register_components():
	# Регистрация типов
	ComponentType.register_type(ComponentType.Name.AI)
	ComponentType.register_type(ComponentType.Name.Animation)
	ComponentType.register_type(ComponentType.Name.CharacterBody3D)
	ComponentType.register_type(ComponentType.Name.Formation)
	ComponentType.register_type(ComponentType.Name.Gathering)
	ComponentType.register_type(ComponentType.Name.Gatherable)
	ComponentType.register_type(ComponentType.Name.Input)
	ComponentType.register_type(ComponentType.Name.MeshInstance)
	ComponentType.register_type(ComponentType.Name.Move)
	ComponentType.register_type(ComponentType.Name.Navigation)
	ComponentType.register_type(ComponentType.Name.Position)
	ComponentType.register_type(ComponentType.Name.RandomMovement)
	ComponentType.register_type(ComponentType.Name.Rotate)
	ComponentType.register_type(ComponentType.Name.State)


	print("Registered component types: ", ComponentType.REGISTRY)
	
func register_systems():
	# Регистрация систем
	var sys_StateSystem = preload("res://ECS/systems/StateSystem.gd")
	var sys_BehaviorSystem = preload("res://ECS/systems/BehaviorSystem.gd")
	var sys_GatheringSystem = preload("res://ECS/systems/GatheringSystem.gd")
	var sys_NavigationSystem = preload("res://ECS/systems/NavigationSystem.gd")
	var sys_MoveSystem = preload("res://ECS/systems/MoveSystem.gd")
	var sys_RotateSystem = preload("res://ECS/systems/RotateSystem.gd")
	var sys_AnimationSystem = preload("res://ECS/systems/AnimationSystem.gd")
	var sys_FormationSystem = preload("res://ECS/systems/FormationSystem.gd")
	var sys_RandomMovementSystem = preload("res://ECS/systems/RandomMovementSystem.gd")
	
	system_registry.register_system(sys_StateSystem.new(ecs_manager, event_bus),"StateSystem")
	system_registry.register_system(sys_BehaviorSystem.new(ecs_manager, async_queue, event_bus),"BehaviorSystem")
	system_registry.register_system(sys_GatheringSystem.new(ecs_manager, async_queue, event_bus),"GatheringSystem")
	system_registry.register_system(sys_NavigationSystem.new(ecs_manager),"NavigationSystem")
	system_registry.register_system(sys_MoveSystem.new(ecs_manager),"MoveSystem")
	system_registry.register_system(sys_RotateSystem.new(ecs_manager),"RotateSystem")
	system_registry.register_system(sys_AnimationSystem.new(ecs_manager, event_bus, async_queue),"AnimationSystem")
	system_registry.register_system(sys_FormationSystem.new(ecs_manager,self),"FormationSystem")
	system_registry.register_system(sys_RandomMovementSystem.new(ecs_manager),"RandomMovementSystem")


func create_entity(dict:Dictionary):	# Создание скелета
	for i in dict:
		var skeleton = await entity_factory.create_skeleton(dict[i])
		ecs_logger.log_entity(skeleton, "Created")
