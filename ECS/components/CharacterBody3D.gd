# components/CharacterBody3DComponent.gd
extends Resource
class_name CharacterBody3DComponent

var character_body_3d: CharacterBody3D = null
var nav_agent: NavigationAgent3D = null
var animation_player: AnimationPlayer = null
var rig: Node3D = null
var label_3d: Label3D = null
var mark: Sprite3D = null
