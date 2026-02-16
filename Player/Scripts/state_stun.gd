class_name State_Stun extends State

@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10
@export var invulnerable_duration : float = 1
@export var particle_settings : HitParticleSettings

var hurt_box : HurtBox
var direction : Vector2

var next_state : State = null

@onready var idle : State = $"../Idle"	
@onready var death: State_Death = $"../Death"

func init() -> void:
	player.player_damaged.connect( _player_damaged)

func Enter() -> void:
	$"../../Sprite2D/AttackEffectSprite2".visible = false
	player.animation_player.animation_finished.connect( _animation_finished)
	direction = player.global_position.direction_to( hurt_box.global_position)
	EffectManager.set_hitspark("player",player.global_position,false, direction)
	EffectManager.hit_particles(player.global_position + Vector2(0,-20),-direction,particle_settings)
	PlayerManager.shake_camera(hurt_box.damage)
	EffectManager.frame_freeze(0.1,0.26)
	player.velocity = direction * -knockback_speed
	player.SetDirection()
	player.UpdateAnimation("stun")
	player.make_invulnerable( invulnerable_duration )
	player.effect_animation_player.play("damaged")
	pass
	
func Exit() -> void:
	next_state = null
	player.animation_player.animation_finished.disconnect( _animation_finished)
	pass
	
func Process(_delta: float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	return next_state
	
func Physics(_delta: float) -> State:
	return null	

func HandleInput( _event: InputEvent) -> State:
	return null		

func _player_damaged( _hurt_box : HurtBox) -> void:
	hurt_box = _hurt_box
	if state_machine.current_state != death:
		state_machine.change_state( self)
	pass
	
func _animation_finished( _a: String) -> void:
	next_state = idle
	if player.hp <= 0:
		next_state = death	
