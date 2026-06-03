# --- enemy_state_circle.gd ---
class_name BossStateCircle extends EnemyState

@export var anim_name : String = "walk"
@export var circle_speed : float = 35.0
@export var turn_rate: float = 0.25

@export_category("Circle Behavior")
@export var circle_distance : float = 80.0  # Ideal distance from player
@export var circle_duration_min : float = 2.0
@export var circle_duration_max : float = 4.0
@export var distance_tolerance : float = 15.0  # Allowed variance

@export_category("State Transitions")
@export var attack_state : BossStateAttack
@export var chase_state : BossStateChase
@export var idle_state : EnemyState

@onready var vision_area: VisionArea = $"../../VisionArea"
@onready var line_of_sight_ray: RayCast2D = $"../../LineOfSightRay"

var _direction : Vector2
var _circle_timer : float = 0.0
var _circle_duration : float = 0.0
var _circle_clockwise : bool = true

func init() -> void:
	pass

func enter() -> void:
	$"../../Label".text = "circle"
	
	# Initialize circling
	_circle_timer = 0.0
	_circle_duration = randf_range(circle_duration_min, circle_duration_max)
	_circle_clockwise = randf() > 0.5
	
	enemy.update_animation(anim_name)
	print("Boss circling for ", _circle_duration, " seconds")
	pass

func exit() -> void:
	pass

func process(_delta: float) -> EnemyState:
	var distance_to_player = enemy.global_position.distance_to(enemy.player.global_position)
	if PlayerManager.player.hp <= 0:
		return idle_state
	
	# Check if in attack range
	if enemy._in_attack_range():
		# Circled long enough, go attack
		if _circle_timer >= _circle_duration:
			return attack_state
	
	# Check if player moved too far away
	if distance_to_player > circle_distance + 45:  # Add buffer zone
		# Player escaped, chase again
		return chase_state
	
	# Check if lost line of sight
	if not _has_line_of_sight():
		return chase_state
	
	# Continue circling
	_circle_timer += _delta
	_circle_movement(distance_to_player)
	
	# Update animation
	if enemy.set_direction(_direction):
		enemy.update_animation(anim_name)
	
	return null

func physics(_delta: float) -> EnemyState:
	return null

func _circle_movement(distance_to_player: float) -> void:
	var to_player = enemy.player.global_position - enemy.global_position
	var to_player_normalized = to_player.normalized()
	
	# Calculate perpendicular direction for circling
	var perpendicular : Vector2
	if _circle_clockwise:
		perpendicular = Vector2(to_player_normalized.y, -to_player_normalized.x)
	else:
		perpendicular = Vector2(-to_player_normalized.y, to_player_normalized.x)
	
	# Distance correction to maintain circle_distance
	var distance_error = distance_to_player - circle_distance
	var distance_correction : Vector2 = Vector2.ZERO
	
	if abs(distance_error) > distance_tolerance:
		if distance_error > 0:
			# Too far, move toward player
			distance_correction = -to_player_normalized * 0.4
		else:
			# Too close, move away from player
			distance_correction = to_player_normalized * 0.4
	
	# Combine circling and distance correction
	var circle_direction = (perpendicular + distance_correction).normalized()
	
	_direction = lerp(_direction, circle_direction, turn_rate)
	enemy.velocity = _direction * circle_speed
	pass

func _has_line_of_sight() -> bool:
	if not vision_area.get_overlapping_bodies().has(enemy.player):
		return false
	
	line_of_sight_ray.target_position = enemy.to_local(enemy.player.global_position)
	line_of_sight_ray.force_raycast_update()
	var collider = line_of_sight_ray.get_collider()
	return is_instance_valid(collider) and collider.is_in_group("player")
