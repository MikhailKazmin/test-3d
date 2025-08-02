# components/StateComponent.gd
extends BaseComponent
class_name StateComponent

enum State {
	RISING,
	DEATH_POSE, 
	STANDING_UP,
	IDLE,
	MOVING,
	ATTACKING,
	GATHERING
}
var label_3d: Label3D = null
var mark: Sprite3D = null
var current_state: State = State.RISING
var is_selected: bool = false


func reset():
	current_state = State.RISING
	is_selected = false
	label_3d = null
	mark = null
