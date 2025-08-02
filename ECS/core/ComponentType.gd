# ecs/ComponentType.gd
class_name ComponentType

static var NEXT_TYPE_ID: int = 0
static var REGISTRY: Dictionary = {}

static func register_type(name: ComponentType.Name) -> int:
	if not REGISTRY.has(name):
		REGISTRY[name] = 1 << NEXT_TYPE_ID
		NEXT_TYPE_ID += 1
	return REGISTRY[name]

static func get_mask(name: ComponentType.Name) -> int:
	return REGISTRY.get(name, 0)
	
enum Name
{
	AI,
	Animation,
	CharacterBody3D,
	Formation,
	Gathering,
	Gatherable,
	Input,
	MeshInstance,
	Move,
	Navigation,
	Position,
	RandomMovement,
	Rotate,
	State
}
	
