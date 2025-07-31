extends Unit
class_name Skeleton

signal rise_started
signal rise_completed
signal ready_for_movement
signal gather_resource(resource)

@export var mesh_instance: MeshInstance3D

func _ready() -> void:
	components = {
		"state": $Components/State,
		"input": $Components/Input,
		"navigation": $Components/Navigation,
		"gathering": $Components/Gathering,
		"randomMovement": $Components/RandomMovement,
		"formation": $Components/Formation,
		"movement": $Components/Move,
		"animation": $Components/Animation,
		"rotate": $Components/Rotate
	}
	for component in components.values():
		if component is BaseComponentComposition:
			component.init(self)
	for component in components.values():
		if component is BaseComponentComposition:
			component._setup()

	# Инициализируем состояние
	var state = components["state"] as SkeletonState
	if state and not state.current_state == SkeletonState.State.RISING:
		state.set_state(SkeletonState.State.RISING)

func _process(delta: float) -> void:
	for component in components.values():
		if component is BaseComponentComposition and component.is_active:
			component.process(delta)

func _physics_process(delta: float) -> void:
	for component in components.values():
		if component is BaseComponentComposition and component.is_active:
			component.physics_process(delta)

func _input(event: InputEvent) -> void:
	for component in components.values():
		if component is BaseComponentComposition and component.is_active:
			component._input(event)
