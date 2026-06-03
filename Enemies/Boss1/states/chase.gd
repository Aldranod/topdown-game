# --- enemy_state_chase.gd (Corrected and Simplified) ---
class_name BossStateChase extends EnemyState
const PATHFINDER : PackedScene = preload("res://Enemies/pathfinder.tscn")

@export var anim_name : String = "walk"
@export var chase_speed : float = 40.0
@export var turn_rate: float = 0.25
@export var can_charge : bool = false
@onready var charge_ray: RayCast2D = $"../../ChargeRay"

@export_category("AI")
@export var vision_area : VisionArea
@export var attack_area : HurtBox
@export var min_charge_distance: float = 50.0
@export var state_aggro_duration : float = 3.0 # How long to chase after losing sight
@export var state_patience_duration: float = 10.0 # NEW: How long to chase without line of sight
@export var idle_state : EnemyState
@export var telegraph_state: BossStateTelegraph
@export var circle_state: BossStateCircle
@export var circle_trigger_distance: float = 80.0 

@onready var attack_state: BossStateAttack = $"../Attack"
@onready var boss: Boss1 = $"../.."

var pathfinder : Pathfinder
var _aggro_timer : float = 0.0
#var _patience_timer :float = 0.0
var _direction : Vector2

func init() -> void:
	pass
	
func enter() -> void:
	if boss.stage2:
		chase_speed = 160
		state_aggro_duration = 1
	$"../../Label".text = "chase"
	$"../..".set_collision_mask_value(5, true)
	$"../..".set_collision_mask_value(7, true) 
	$"../..".set_collision_mask_value(8, true) 
	pathfinder = PATHFINDER.instantiate() as Pathfinder
	enemy.add_child(pathfinder)
	_aggro_timer = state_aggro_duration
	#_patience_timer = state_patience_duration # NEW: Reset patience on entering chase
	enemy.update_animation(anim_name)
	#if attack_area:
		#attack_area.monitoring = true
	pass
	
func exit() -> void:
	pathfinder.queue_free()
	pass
	
func process( _delta: float ) -> EnemyState:
	#var distance_to_player = enemy.global_position.distance_to(enemy.player.global_position)
	if PlayerManager.player.hp > 0:
		if enemy._in_attack_range():
			return attack_state
		# First, we do a cheap check to see if the player is still in our general area.
		#if vision_area.get_overlapping_bodies().has(enemy.player):
			#_aggro_timer = state_aggro_duration
			#var has_line_of_sight = _check_line_of_sight()
			#if has_line_of_sight:
				#_patience_timer = state_patience_duration
				##var distance_to_player = enemy.global_position.distance_to(enemy.player.global_position)
				#if distance_to_player > min_charge_distance and can_charge:
					#return telegraph_state
			#else:
				#_patience_timer -= _delta
				#if _patience_timer <= 0:
					#return idle_state # Patience has run out, give up.	
		else:
			if PlayerManager.player.state_machine.current_state == State_Heal and enemy.hp < 60:
				return $"../Idle".call_help_check()
			# If the player is NOT in our vision cone, start the countdown to give up.
			_aggro_timer -= _delta
			if _aggro_timer <= 0:
				return idle_state # Give up and go back to idle.
		# The pathfinding and movement logic runs regardless,
		# so the enemy continues to the player's last known position.
		_direction = lerp(_direction, pathfinder.move_dir, turn_rate)
		enemy.velocity = _direction * chase_speed
		if enemy.set_direction(_direction):
			enemy.update_animation( anim_name)	
	return null

func physics( _delta: float ) -> EnemyState:
	return null

func _check_line_of_sight() -> bool:
	var line_of_sight_ray : RayCast2D = $"../../LineOfSightRay" # Or use @onready var for it
	line_of_sight_ray.target_position = enemy.to_local(enemy.player.global_position)
	line_of_sight_ray.force_raycast_update()
	var collider = line_of_sight_ray.get_collider()
	return is_instance_valid(collider) and collider.is_in_group("player")
