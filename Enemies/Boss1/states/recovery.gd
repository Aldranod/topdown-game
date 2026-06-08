# --- enemy_state_recovery.gd ---
class_name BossStateRecovery extends EnemyState

@export var anim_name: String = "idle" # Or a specific "tired" animation
@export var recovery_duration: float = 1.0 # How long the enemy waits (in seconds)

@export var next_state: EnemyState # Where to go after recovery (the Chase state)
@onready var stage2: bool = $"../..".stage2
var _timer: float

func enter() -> void:
	if stage2:
		recovery_duration = 0.6
	$"../../Sprite2D/AttackHurtBox".monitoring = false	
	$"../../Label".text = "recovery"
	_timer = recovery_duration
	enemy.velocity = Vector2.ZERO # Stop all movement
	enemy.update_animation(anim_name)

func exit() -> void:
	pass

func process(_delta: float) -> EnemyState:
	if PlayerManager.player.state_machine.current_state == State_Heal and enemy.hp < 60:
		return $"../Idle".call_help_check()
	_timer -= _delta
	
	# When the timer runs out, transition to the next state.
	if _timer <= 0.0:
		return next_state
		
	return null

func physics(_delta: float) -> EnemyState:
	return null
