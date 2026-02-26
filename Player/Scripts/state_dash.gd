class_name State_Dash extends State

@export var move_speed : float = 200.0
@export var effect_delay : float = 0.1
@export var dash_audio : AudioStream
@onready var attack: State = $"../Attack"
@onready var second_attack: State = $"../SecondAttack"
@onready var third_attack: State_ThirdAttack = $"../ThirdAttack"
@onready var idle: State = $"../Idle"

var direction : Vector2 = Vector2.ZERO
var next_state : State = null
var effect_timer : float = 0
	
func Enter() -> void:
	$"../../Sprite2D/AttackEffectSprite2".visible = false
	player.invulnerable = true
	player.set_collision_mask_value(9, false)	
	player.UpdateAnimation("dash")
	player.animation_player.animation_finished.connect( _on_animation_finished)
	direction = player.direction
	if direction == Vector2.ZERO:
		direction = player.cardinal_direction
	if dash_audio:
		player.audio.stream = dash_audio
		player.audio.play()	
	effect_timer = 0	 
	pass
	
func Exit() -> void:
	player.set_collision_mask_value(9, true)
	player.invulnerable = false
	player.animation_player.animation_finished.disconnect( _on_animation_finished)
	next_state = null
	pass
	
func Process(_delta: float) -> State:
	player.velocity = direction * move_speed
	effect_timer -= _delta
	if effect_timer < 0:
		effect_timer = effect_delay
		spawn_effect()
	return next_state

func Physics(_delta: float) -> State:
	return null	

func HandleInput(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		if PlayerManager.player.third_attack_window_open:
			return third_attack
		if PlayerManager.player.combo_window_open:
			return second_attack
		if PlayerManager.player.attack_window_open:
			return attack
	if _event.is_action_pressed("up") or _event.is_action_pressed("down") or _event.is_action_pressed("left") or _event.is_action_pressed("right") :
			next_state = idle
			return idle		
	return null		
	
func _on_animation_finished(anim_name : String) -> void:
	PlayerManager.player.start_dash_cooldown()
	next_state = idle
	pass
	
func spawn_effect() -> void:
	var effect : Node2D = Node2D.new()
	player.get_parent().add_child( effect )
	effect.global_position = player.global_position - Vector2( 0, 0.1 )
	effect.modulate = Color( 1.5, 0.2, 1.25, 0.75 )
	
	var sprite_copy : Sprite2D = player.sprite.duplicate()
	await get_tree().process_frame
	effect.add_child( sprite_copy )
	
	var tween : Tween = create_tween()
	tween.set_ease( Tween.EASE_OUT )
	tween.tween_property( effect, "modulate", Color( 1,1,1,0.0 ), 0.2 )
	tween.chain().tween_callback( effect.queue_free )
	pass
							
