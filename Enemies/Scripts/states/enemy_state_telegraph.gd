# --- enemy_state_telegraph.gd ---
class_name EnemyStateTelegraph extends EnemyState

# A specific animation for the telegraph, e.g., the enemy glows or rears back.
@export var anim_name: String = "stun" 
# How long the warning lasts. 0.3 to 0.5 seconds is typical.
@export var telegraph_duration: float = 0.4 
# Optional sound effect for the warning.
@export var telegraph_audio: AudioStream 

# Where to go after the telegraph is finished (this will be the Charge state).
@export var next_state: EnemyState 

var _timer: float

func enter() -> void:
	_timer = telegraph_duration
	
	# Stop moving. This is the "pause" before the attack.
	enemy.velocity = Vector2.ZERO
	
	# Lock onto the player's current position to telegraph intent.
	var player_direction = enemy.global_position.direction_to(enemy.player.global_position)
	enemy.set_direction(player_direction)
	
	# Play the warning animation and sound.
	enemy.update_animation(anim_name)
	if telegraph_audio:
		enemy.get_node("AudioStreamPlayer2D").stream = telegraph_audio
		enemy.get_node("AudioStreamPlayer2D").play()

func exit() -> void:
	pass

func process(_delta: float) -> EnemyState:
	_timer -= _delta
	
	# Once the timer runs out, transition to the next state (the charge).
	if _timer <= 0.0:
		return next_state
		
	return null

func physics(_delta: float) -> EnemyState:
	return null
