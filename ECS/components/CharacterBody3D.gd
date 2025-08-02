# components/CharacterBody3DComponent.gd
extends BaseComponent
class_name CharacterBody3DComponent

var character_body_3d: CharacterBody3D = null
var nav_agent: NavigationAgent3D = null
var animation_player: AnimationPlayer = null
var rig: Node3D = null


func reset():
	character_body_3d = null
	nav_agent = null
	animation_player = null
	rig = null
