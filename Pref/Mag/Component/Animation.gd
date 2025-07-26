extends BaseAnimation
class_name PlayerAnimation
@export  var animation_player: AnimationPlayer

var input: PlayerInput
var movement: PlayerMove

var current_animation: String = ""

func _setup() -> void:
	input = entity.get_component(PlayerInput)
	movement = entity.get_component(PlayerMove)
	if !input or !movement:
		push_error("Missing required components!")
		disable()

func process(delta: float) -> void:
	if not is_active:
		return
	
	var input_comp = entity.get_component(PlayerInput)

	if input_comp.attack_pressed:
		play_animation("Spellcast_Shoot")
		await animation_player.animation_finished
		entity.get_component(PlayerAttack).is_attacking = true
		entity.get_component(PlayerInput).attack_pressed = false
		
	elif input_comp.aim_pressed:
		play_animation("Spellcasting")  # Добавьте эту анимацию
	elif not entity.is_on_floor():
		play_animation("Jump_Start" if movement.velocity.y > 0 else "Jump_Land")
	elif movement.velocity.length() > 0.1:
		play_animation("Running_A")
	else:
		play_animation("Idle")

func play_animation(anim_name: String, force: bool = false) -> void:
	if not force and current_animation == anim_name:
		return
	
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
		current_animation = anim_name
