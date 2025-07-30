# components/StateComponent.gd
extends Resource
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

var current_state: State = State.RISING
var is_selected: bool = false
