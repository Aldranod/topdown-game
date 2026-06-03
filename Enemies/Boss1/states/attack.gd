class_name BossStateAttack extends EnemyState

@export var attack_cooldown_min : float = 0.2
@export var attack_cooldown_max : float = 0.4
@export var rush_forward : bool = false
@export var rush_speed : float = 0
@export var rush_speed_curve: Curve
var anim_name : String = "attack"
var _animation_finished : bool = false
var _direction :  Vector2
@onready var attack_hurt_box: HurtBox = $"../../Sprite2D/AttackHurtBox"

@export_category("AI")

@export var idle_state : EnemyState
@onready var chase_state: BossStateChase = $"../Chase"

func init() -> void:
	pass
	
func enter() -> void:
	$"../../Label".text = "attack"
	#if attack_hurt_box:
		#attack_hurt_box.monitoring = true	
	$"../..".set_collision_mask_value(5, true) 	
	_animation_finished = false
	_direction = enemy.global_position.direction_to(PlayerManager.player.global_position)
	enemy.set_direction(_direction)
	#if rush_forward:
		#enemy.velocity = _direction * rush_speed
	#else:	
		#enemy.velocity = Vector2.ZERO
	attack_select()
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect( _on_animation_finished)
	pass
	
func exit() -> void:
	enemy.animation_player.animation_finished.disconnect( _on_animation_finished)
	#if attack_hurt_box:
		#attack_hurt_box.monitoring = false
	pass
	
func process( _delta: float ) -> EnemyState:
	if PlayerManager.player.hp <= 0:
		return idle_state
	if rush_forward:
		var sample : float = rush_speed_curve.sample($"../../AnimationPlayer".current_animation_position/$"../../AnimationPlayer".current_animation_length)
		enemy.velocity = _direction * rush_speed * sample
	else:	
		enemy.velocity = Vector2.ZERO	
	if _animation_finished == true:	
#		#random between attack again, flee and idle
		return chase_state
	return null

func physics( _delta: float ) -> EnemyState:
	return null

func _on_animation_finished( _a : String) -> void:
	enemy.velocity = Vector2.ZERO
	await get_tree().create_timer(randf_range(attack_cooldown_min, attack_cooldown_max)).timeout
	_animation_finished = true	

func attack_select() -> void:
	if $"../../AnimationPlayer".has_animation("attack2_down"):
		var rand = randi_range(0,1)
		if rand == 0:
			anim_name = "attack"
		else:
			anim_name = "attack2"
	else:
		anim_name = "attack"			
	pass
