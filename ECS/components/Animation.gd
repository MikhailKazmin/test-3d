# components/AnimationComponent.gd
extends BaseComponent
class_name AnimationComponent

var current_phase: String = "rising"
var is_gathering_anim: bool = false
var last_animation: String = ""

func reset():
	current_phase = "rising"
	is_gathering_anim = false
	last_animation = ""
