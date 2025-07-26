extends BaseAttack
class_name SkeletonAttack

@onready var crosshair: TextureRect = $"../../../CanvasLayer/HUD/Crosshair"
@export var hand_marker: Marker3D
var is_attacking := false

var input: SkeletonInput
var camera: SkeletonCamera


func init(_entity: Node) -> void:
	super.init(_entity)

func _setup():
	input = entity.get_component(SkeletonInput)

func _input(event):
	pass

func process(delta: float) -> void:
	if not is_active:
		return
