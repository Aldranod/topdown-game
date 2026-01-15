class_name EnemyStateIdle extends EnemyState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min : float = 0.5
@export var state_duration_max : float = 1.5
@export var after_idle_state : EnemyState
@export var chase_state: EnemyStateChase # Add an export for the chase state
@export var ambush: bool = false

var _timer : float = 0.0

# We need references to the vision components.
# This assumes the Chase state holds the reference to the VisionArea.
@onready var vision_area: VisionArea = $"../../VisionArea"
@onready var line_of_sight_ray: RayCast2D = $"../../LineOfSightRay"
@onready var attack_state: EnemyStateAttack = $"../Attack"
@onready var idle: EnemyStateIdle = $"."

func init() -> void:
	pass
	
func enter() -> void:
	enemy.velocity = Vector2.ZERO
	_timer = randf_range(state_duration_min, state_duration_max)
	enemy.update_animation( anim_name)
	pass
	
func exit() -> void:
	pass
	
func process( _delta: float ) -> EnemyState:
	if PlayerManager.player.hp > 0:
		if enemy._in_attack_range():
			#$"../..".set_collision_mask_value(5, true)
			ambush = false
			return attack_state
		# --- NEW LINE OF SIGHT LOGIC ---
		# First, do a cheap check to see if the player is even nearby.
		if vision_area:
			if vision_area.get_overlapping_bodies().has(enemy.player):
				# If they are, do the expensive raycast check.
				line_of_sight_ray.target_position = enemy.to_local(enemy.player.global_position)
				line_of_sight_ray.force_raycast_update()
				
				var collider = line_of_sight_ray.get_collider()
				
				# If the first thing we see is the player, start chasing!
				if is_instance_valid(collider) and collider.is_in_group("player"):
					if chase_state:
						#$"../..".set_collision_mask_value(5, true)
						ambush = false 
						return chase_state

	# If we don't have line of sight, just continue with the normal idle timer.
	_timer -= _delta
	if _timer <= 0 and not ambush:
		return after_idle_state
	else:	
		return idle	
	return null

func physics( _delta: float ) -> EnemyState:
	return null	
