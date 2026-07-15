# --- enemy_state_flee.gd ---
class_name EnemyStateFlee extends EnemyState

const PATHFINDER : PackedScene = preload("res://Enemies/pathfinder.tscn")
@export var anim_name : String = "walk"
@export var flee_speed : float = 60.0
@export var turn_rate: float = 0.25

@export_category("AI")
@export var vision_area : VisionArea
@export var flee_duration: float = 3.0  # How long to flee before returning to chase
@export var chase_state: EnemyStateChase

var pathfinder : Pathfinder
var _direction : Vector2
var _flee_timer : float = 0.0

func init() -> void:
	pass

func enter() -> void:
	$"../../../Goblin5/Label".text = "flee"
	if not enemy.can_shoot:	
		$"../../IndicatorSprite2D".visible = true
		$"../../IndicatorSprite2D".play("fear")
	$"../..".set_collision_mask_value(5, true)
	pathfinder = PATHFINDER.instantiate() as Pathfinder
	enemy.add_child(pathfinder)
	_flee_timer = flee_duration  # Start the flee timer
	enemy.update_animation(anim_name)
	pass
	
func exit() -> void:
	if not enemy.can_shoot:
		$"../../IndicatorSprite2D".visible = false
	if is_instance_valid(pathfinder):
		pathfinder.queue_free()
	pass
	
func process( _delta: float ) -> EnemyState:
	# Decrement the flee timer
	_flee_timer -= _delta
	
	# If flee duration is over, return to chase or shoot
	if _flee_timer <= 0.0:
		if enemy.can_shoot:
			return $"../Idle"
		else:	
			return chase_state
	
	# Calculate flee direction (opposite of player direction)
	var player_direction = enemy.global_position.direction_to(enemy.player.global_position)
	var flee_direction = -player_direction  # Invert to flee away
	
	# Use pathfinder but invert the desired direction for obstacle avoidance
	_direction = lerp(_direction, pathfinder.move_dir * -1, turn_rate)
	enemy.velocity = _direction * flee_speed
	if enemy.set_direction(_direction):
		enemy.update_animation(anim_name)
	
	return null

func physics( _delta: float ) -> EnemyState:
	return null
