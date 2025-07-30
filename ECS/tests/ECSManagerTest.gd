# ecs/ECSManagerTest.gd
extends Node

func _ready():
	# Инициализация как в World.gd (упрощённо)
	var ecs = ECSManager.new()
	var pool = ComponentPool.new()
	var bus = EventBus.new()
	var queue = AsyncEventQueue.new()
	add_child(ecs)
	add_child(pool)
	add_child(bus)
	add_child(queue)

	# Регистрация типов (все)
	ComponentType.register_type("State")
	# ... все остальные

	var factory = EntityFactory.new(ecs, pool, bus)
	var skeleton = factory.create_skeleton(Vector3(0,0,0))
	assert(skeleton.has_components(ComponentType.get_mask("State") | ComponentType.get_mask("Animation")), "Components missing")

	# Simulate rise
	await get_tree().create_timer(4.0).timeout
	var state_comp = skeleton.get_component(ComponentType.get_mask("State"))
	assert(state_comp.current_state == StateComponent.State.IDLE, "Rise failed")
	print("All tests OK")
