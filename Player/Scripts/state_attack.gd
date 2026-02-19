class_name State_Attack extends State

var direction : Vector2
var attacking : bool = false
var timer : float = 0
var combo : int = 1

@export var combo_time_window : float = 0.2
@export var knockback_speed : float = 0.0
@export var charge_speed : float = 0.0
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
	do_attack()
	animation_player.animation_finished.connect(EndAttack)
	hurt_box.did_damage.connect(_on_hit_landed)
	#player.start_combo()
	#hurt_box.attack_type = "sword"
	#player.UpdateAnimation("attack")
	##attack_anim.play("attack_" + player.AnimDirection())
	#player.velocity = player.cardinal_direction * charge_speed
	#animation_player.animation_finished.connect(EndAttack)
	#hurt_box.did_damage.connect(_on_hit_landed)
	#audio.stream = attack_sound
	#audio.pitch_scale = randf_range(0.9, 1.1)
	#audio.play()
	#attacking = true
	#await get_tree().create_timer(0.075).timeout
	#if attacking:
		#hurt_box.monitoring = true
	pass
	
func Exit() -> void:
	timer = 0
	combo = 1
	$"../../Sprite2D/AttackEffectSprite2".visible = false
	animation_player.animation_finished.disconnect(EndAttack)
	hurt_box.did_damage.disconnect(_on_hit_landed)
	attacking = false
	hurt_box.monitoring = false
	await get_tree().process_frame
	pass
	
func Process(_delta: float) -> State:
	timer -= _delta
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
	if _event.is_action_pressed("attack"):
		timer = combo_time_window
		#do_attack()
	if _event. is_action_pressed("dash"):
		if player.can_dash():
			player.start_dash_cooldown()
			return dash  # Cancel attack and dash instead
	return null						

func EndAttack( _newAnimName : String) -> void:
	print("endattack timer: "+str(timer) )
	if combo > 2:
		attacking = false
	if timer > 1:
		combo = wrapi(combo+1,2,4)
		do_attack()
	else:	
		if Input.is_action_pressed("attack"):
			state_machine.change_state(charge_attack)
		attacking = false
	
func _on_hit_landed() -> void:
	var knockback_direction = direction if player.cardinal_direction != Vector2.DOWN else -direction
	player.velocity = knockback_direction * knockback_speed

func do_attack() -> void:
	attacking = true
	var anim_name: String = "attack"
	print("doattack combo: "+str(combo) )
	if combo > 1:
		anim_name ="attack" + str(combo)
	player.UpdateAnimation(anim_name)
	print(anim_name)
	hurt_box.attack_type = "sword"
	#player.UpdateAnimation("attack")
	#attack_anim.play("attack_" + player.AnimDirection())
	player.velocity = player.cardinal_direction * charge_speed
	audio.stream = attack_sound
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	pass
