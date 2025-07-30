# components/AnimationComponent.gd
extends Resource
class_name AnimationComponent

var current_phase: String = "rising"
var is_gathering_anim: bool = false
var last_animation: String = ""
