extends Entity
class_name Player

@export var caster: PentagramCaster
@export var available_pentagram_effects: Array[PentagramEffect]
@export var pentagram_wheel: PentagramWheel  # Ссылка на колесо выбора

func _ready() -> void:
	components = {
	"input": $Components/PlayerInput,
	"movement": $Components/PlayerMove,
	"camera": $Components/PlayerCamera,
	"animation": $Components/PlayerAnimation,
	"attack": $Components/PlayerAttack
}
	for component in components.values():
		if component is BaseComponent:
			component.init(self)
	for component in components.values():
		if component is BaseComponent:
			component._setup()

func _process(delta: float) -> void:
	for component in components.values():
		if component is BaseComponent and component.is_active:
			component.process(delta)

func _physics_process(delta: float) -> void:
	for component in components.values():
		if component is BaseComponent and component.is_active:
			component.physics_process(delta)

func _input(event: InputEvent) -> void:
	for component in components.values():
		if component is BaseComponent and component.is_active:
			component._input(event)
