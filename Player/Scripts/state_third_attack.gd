class_name State_ThirdAttack extends State

var direction : Vector2
var attacking : bool = false
@export var knockback_speed : float = 80.0
@export var charge_speed : float = 150.0
@export var attack_sound : AudioStream
@export_range(1,20,0.5) var decelerate_speed : float = 5.0
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var attack_anim: AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

@onready var walk: State = $"../Walk"	
@onready var idle: State = $"../Idle"
@onready var charge_attack: State = $"../ChargeAttack"
@onready var dash: State_Dash = $"../Dash"
@onready var hurt_box: HurtBox = %AttackHurtBox

func Enter() -> void:	
	var mouse_pos = player.get_global_mouse_position()
	var direction_to_mouse = (mouse_pos - player.global_position).normalized()
	player.cardinal_direction = direction_to_mouse
	
	
	# Calculate move direction and apply velocity
	var move_direction = direction_to_mouse
	player.velocity = move_direction * charge_speed
	player.face_target(player.get_global_mouse_position())
	player.start_attack()
	hurt_box.attack_type = "sword"
	player.UpdateAnimation("attack2")
	animation_player.animation_finished.connect(EndAttack)
	hurt_box.did_damage.connect(_on_hit_landed)
	audio.stream = attack_sound
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	attacking = true
	pass
	
func Exit() -> void:
	player.combo_window_open = false
	player.third_attack_window_open = false 
	animation_player.animation_finished.disconnect(EndAttack)
	hurt_box.did_damage.disconnect(_on_hit_landed)
	attacking = false
	hurt_box.monitoring = false
	#await get_tree().create_timer(1).timeout
	await get_tree().process_frame
	pass
	
func Process(_delta: float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk	
	return null

func Physics(_delta: float) -> State:
	return null	

func HandleInput(_event: InputEvent) -> State:
	if _event. is_action_pressed("dash"):
		if player.can_dash():
			player.start_dash_cooldown()
			return dash  # Cancel attack and dash instead
	return null							

func EndAttack( _newAnimName : String) -> void:
	if Input.is_action_pressed("attack"):
		state_machine.change_state(charge_attack)
	attacking = false
	
func _on_hit_landed() -> void:
	var knockback_direction = -player.cardinal_direction
	player.velocity = knockback_direction * knockback_speed
