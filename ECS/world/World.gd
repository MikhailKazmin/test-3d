extends Node3D

@onready var ecs_manager = preload("res://ECS/core/ECSManager.gd").new()
@onready var async_queue = preload("res://ECS/core/AsyncEventQueue.gd").new()
@onready var system_registry = preload("res://ECS/core/SystemRegistry.gd").new()
@onready var event_bus = preload("res://ECS/world/EventBus.gd").new()
@onready var component_pool = preload("res://ECS/core/ComponentPool.gd").new()
@onready var ecs_logger = preload("res://ECS/core/ECSLogger.gd").new()
@onready var entity_factory = EntityFactory.new(ecs_manager, component_pool, event_bus)

func _ready():
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

	# Регистрация типов
	ComponentType.register_type("State")
	ComponentType.register_type("Navigation")
	ComponentType.register_type("Gathering")
	ComponentType.register_type("RandomMovement")
	ComponentType.register_type("Formation")
	ComponentType.register_type("Move")
	ComponentType.register_type("Animation")
	ComponentType.register_type("Rotate")
	ComponentType.register_type("Position")
	ComponentType.register_type("CharacterBody3D")

	print("Registered component types: ", ComponentType.REGISTRY)
	await get_tree().create_timer(0.5).timeout
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
	system_registry.register_system(sys_FormationSystem.new(ecs_manager),"FormationSystem")
	system_registry.register_system(sys_RandomMovementSystem.new(ecs_manager),"RandomMovementSystem")
	await get_tree().create_timer(1).timeout
	# Создание скелета
	for i in range(0, 10):
		var skeleton = await entity_factory.create_skeleton(Vector3(i * 1.5, -2, 0))
		ecs_logger.log_entity(skeleton, "Created")
