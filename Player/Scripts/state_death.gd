class_name State_Death extends State

@export var exhaust_audio: AudioStream
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

	
func init() -> void:
	pass	
	
func Enter() -> void:
	$"../../Sprite2D/AttackEffectSprite2".visible = false
	player.set_collision_mask_value(9, false)	
	player.animation_player.play("death")
	audio.stream = exhaust_audio
	audio.play()
	PlayerHud.hide_boss_health()
	PlayerHud.show_game_over_screen()
	AudioManager.play_music( null )
	pass
	
func Exit() -> void:
	pass
	
func Process(_delta: float) -> State:
	player.velocity = Vector2.ZERO
	return null

func Physics(_delta: float) -> State:
	return null	

func HandleInput(_delta: InputEvent) -> State:
	return null						
