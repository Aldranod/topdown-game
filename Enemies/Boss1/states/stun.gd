class_name BossStateStun extends EnemyState

@export var anim_name : String = "stun"
@export var knockback_speed : float = 0.0
@export var decelerate_speed : float = 5.0
@export var particles: Array [HitParticleSettings ]
@export_category("AI")
@export var next_state : EnemyState
@export var flee_state: EnemyState  # Add this export
@export var flee_health_threshold: float = 0.5  # Flee at 50% health
@onready var attack_state: BossStateAttack = $"../Attack"

var _damage_position : Vector2
var _direction : Vector2
var _animation_finished : bool = false
var _initial_hp : int = 0  # Track starting health

func init() -> void:
	enemy.enemy_damaged.connect( _on_enemy_damaged)
	# Store initial HP on first init
	if _initial_hp == 0:
		_initial_hp = enemy.hp
	pass
	
func enter() -> void:
	$"../../Label".text = "stun"
	$"../../Sprite2D/AttackHurtBox".monitoring = false
	_animation_finished = false
	_direction = enemy.global_position.direction_to(_damage_position)
	enemy.set_direction(_direction)
	enemy.velocity = _direction * -knockback_speed
	enemy.update_animation(anim_name)
	for p in particles:
		EffectManager.hit_particles(enemy.global_position + Vector2(0,-20),-_direction,p)
	enemy.animation_player.animation_finished.connect( _on_animation_finished)
	pass
	
func exit() -> void:
	enemy.animation_player.animation_finished.disconnect( _on_animation_finished)
	pass
	
func process( _delta: float ) -> EnemyState:
	if _animation_finished:
		#return reaction_select()
		return next_state
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta	
	return null

func physics( _delta: float ) -> EnemyState:
	return null	

func _on_enemy_damaged( hurt_box : HurtBox ) -> void:
	_damage_position = hurt_box.global_position
	state_machine.change_state( self)	

func _on_animation_finished( _a : String) -> void:
	_animation_finished = true	
	
func reaction_select() -> EnemyState:
	#if enemy._in_attack_range():
		#var rand = randi_range(0,1)
		#if rand == 0:
			#return attack_state
		#else:
			#return flee_state	
	#else:
		#return flee_state
	#var rand = randi_range(0,1)
	#if rand == 0:
		#return attack_state
	#else:
		#return flee_state
	if enemy._in_attack_range():
		return attack_state
	else:
		return flee_state	
							
