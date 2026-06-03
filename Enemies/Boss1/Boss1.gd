class_name Boss1 extends Enemy

var consecutive_hits : int = 0
@export var consecutive_hit_threshold : int = 3  # Flee after 3 hits in a row
@export var hit_reset_timer : float = 2.0  # Reset counter after 2 seconds without being hit
var _hit_timer : float = 0.0

var stage2 : bool = false

func _process(_delta):
	
	if $".".hp < 31 and not stage2:
		stage2 = true
		
	if consecutive_hits > 0:
		_hit_timer -= _delta
		if _hit_timer <= 0.0:
			_reset_consecutive_hits()	
	pass	

func _take_damage(hurt_box: HurtBox) -> void:
	super._take_damage(hurt_box)
	
	if hp > 0:  # Only track if still alive
		consecutive_hits += 1
		_hit_timer = hit_reset_timer  # Reset the timer
		print("Consecutive hits: ", consecutive_hits)
		
		# Check if we should flee
		if consecutive_hits >= consecutive_hit_threshold:
			_trigger_flee_from_hits()
	pass	
	
func _trigger_flee_from_hits() -> void:
	print("Boss is fleeing from consecutive hits!")
	# Force state machine to flee state
	if state_machine.has_node("Flee"):
		state_machine.change_state(state_machine.get_node("Flee"))
	_reset_consecutive_hits()
	pass

func _reset_consecutive_hits() -> void:
	consecutive_hits = 0
	_hit_timer = 0.0
	print("Consecutive hit counter reset")
	pass

# Call this when boss successfully attacks player
func on_boss_attack_landed() -> void:
	_reset_consecutive_hits()
	pass
