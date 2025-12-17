# --- enemy_state_charge.gd ---
class_name EnemyStateCharge extends EnemyState

@export var anim_name: String = "chase" # A specific animation for charging
@export var charge_speed: float = 150.0 # Should be faster than chase_speed
@export var charge_duration: float = 1.0 # How long the charge lasts

@export var next_state: EnemyState # Where to go after charging (e.g., back to Chase)
@export var recovery_state: EnemyStateRecovery 

var _charge_direction: Vector2
var _timer: float
var _hit_landed: bool = false

func enter() -> void:
	enemy.invulnerable = true
	# Set the timer for the charge duration.
	_timer = charge_duration
	_hit_landed = false
	
	# IMPORTANT: Lock the direction at the start of the charge.
	# The charge is a straight line to where the player WAS.
	_charge_direction = enemy.global_position.direction_to(enemy.player.global_position)
	
	# Set the velocity. This will be used by the Enemy's move_and_slide().
	enemy.velocity = _charge_direction * charge_speed
	
	# Update visuals.
	enemy.set_direction(_charge_direction)
	enemy.update_animation(anim_name)
	if is_instance_valid(enemy.hurt_box):
		enemy.hurt_box.get_node("CollisionShape2D").disabled = false
		enemy.hurt_box.did_damage.connect(_on_charge_hit)

func exit() -> void:
	# Stop the enemy when the charge state is exited.
	enemy.invulnerable = false
	enemy.velocity = Vector2.ZERO
	if is_instance_valid(enemy.hurt_box):
		enemy.hurt_box.get_node("CollisionShape2D").disabled = true
		if enemy.hurt_box.is_connected("did_damage", Callable(self, "_on_charge_hit")):
			enemy.hurt_box.did_damage.disconnect(_on_charge_hit)

func process(_delta: float) -> EnemyState:
	_timer -= _delta
	# Transition to the next state if the charge duration is over OR if we hit a wall.
	if _hit_landed:
		return next_state
	
	if _timer <= 0.0 or enemy.is_on_wall():
		return recovery_state
	return null

func physics(_delta: float) -> EnemyState:
	# Velocity is maintained by the Enemy node, so nothing is needed here.
	return null
	
func _on_charge_hit():
	print("Charge hit the player! Interrupting.")
	_hit_landed = true	
