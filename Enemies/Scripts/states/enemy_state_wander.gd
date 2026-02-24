class_name EnemyStateWander extends EnemyState

@export var anim_name : String = "walk"
@export var wander_speed : float = 20.0

@export_category("AI")
@export var state_animation_duration : float = 0.5
@export var state_cycles_min : int = 1
@export var state_cycles_max : int = 3
@export var next_state : EnemyState
@export var chase_state: EnemyStateChase # Add an export for the chase state
@export var shoot_state: EnemyStateShoot

@onready var vision_area: VisionArea = $"../../VisionArea"
@onready var line_of_sight_ray: RayCast2D = $"../../LineOfSightRay"
@onready var attack_state: EnemyStateAttack = $"../Attack"

var _timer : float = 0.0
var _direction : Vector2

func init() -> void:
	pass
	
func enter() -> void:
	_timer = randi_range(state_cycles_min, state_cycles_max) * state_animation_duration
	var rand = randi_range(0, 3)
	_direction = enemy.DIR_4[rand]
	enemy.velocity = _direction * wander_speed
	enemy.set_direction(_direction)
	enemy.update_animation(anim_name)
	pass
	
func exit() -> void:
	pass
	
func process( _delta: float ) -> EnemyState:
	if PlayerManager.player.hp > 0:
		if enemy._in_attack_range():
			return attack_state
		# --- NEW LINE OF SIGHT LOGIC ---
		# First, do a cheap check to see if the player is even nearby.
		if vision_area:
			if vision_area.get_overlapping_bodies().has(enemy.player):
				if enemy.can_shoot() :
						return shoot_state
				# If they are, do the expensive raycast check.
				line_of_sight_ray.target_position = enemy.to_local(enemy.player.global_position)
				line_of_sight_ray.force_raycast_update()
				
				var collider = line_of_sight_ray.get_collider()
				
				# If the first thing we see is the player, start chasing!
				if is_instance_valid(collider) and collider.is_in_group("player"):
					if enemy.can_shoot() :
						print("player in shoot range going shoot")
						return shoot_state
					else:	
						return chase_state

	# If we don't have line of sight, just continue with the normal idle timer.
	_timer -= _delta
	if _timer <= 0:
		return next_state
	return null

func physics( _delta: float ) -> EnemyState:
	return null	
