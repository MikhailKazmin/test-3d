extends BaseAnimation
class_name CorpserAnimation
@export  var animation_player: AnimationPlayer

var current_animation: String = ""

func _setup() -> void:
	pass

func process(delta: float) -> void:
	if not is_active:
		return

		play_animation("Idle")

func play_animation(anim_name: String, force: bool = false) -> void:
	if not force and current_animation == anim_name:
		return
	
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
		current_animation = anim_name
