# --- enemy_state_recovery.gd ---
class_name EnemyStateRecovery extends EnemyState

@export var anim_name: String = "idle" # Or a specific "tired" animation
@export var recovery_duration: float = 1.0 # How long the enemy waits (in seconds)

@export var next_state: EnemyState # Where to go after recovery (the Chase state)

var _timer: float

func enter() -> void:
	_timer = recovery_duration
	enemy.velocity = Vector2.ZERO # Stop all movement
	enemy.update_animation(anim_name)

func exit() -> void:
	pass

func process(_delta: float) -> EnemyState:
	_timer -= _delta
	
	# When the timer runs out, transition to the next state.
	if _timer <= 0.0:
		return next_state
		
	return null

func physics(_delta: float) -> EnemyState:
	return null
