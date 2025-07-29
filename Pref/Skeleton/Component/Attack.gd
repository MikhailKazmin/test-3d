extends BaseAttack
class_name SkeletonAttack

@export var hand_marker: Marker3D
var is_attacking := false

var navigation: SkeletonNavigation

func init(_entity: Node) -> void:
	super.init(_entity)

func _setup():
	navigation = entity.get_component(SkeletonNavigation)

func _input(event):
	pass

func process(delta: float) -> void:
	if not is_active:
		return
