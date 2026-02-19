class_name State_Idle extends State

@onready var walk: State = $"../Walk"	
@onready var attack: State = $"../Attack"
@onready var dash: State = $"../Dash"
@onready var second_attack: State = $"../SecondAttack"
@onready var third_attack: State_ThirdAttack = $"../ThirdAttack"
@onready var run: State = $"../Run"

func Enter() -> void:
	player.UpdateAnimation("idle")
	pass
	
func Exit() -> void:
	pass
	
func Process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		# Check if stick is pushed hard enough to run
		if player. stick_intensity >= 0.7:  # Same threshold as run state
			return run  # Go to run instead of walk
		return walk
	player.velocity = Vector2.ZERO
	return null

func Physics(_delta: float) -> State:
	return null	

func HandleInput( _event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
		#if PlayerManager.player.third_attack_window_open:
			#return third_attack
		#if PlayerManager.player.combo_window_open:
			#return second_attack
		#if PlayerManager.player.attack_window_open:
			#return attack	
		#else:	
			#return attack
	elif _event.is_action_pressed("interact"):
		PlayerManager.interact()
	elif _event.is_action_pressed("dash"):
		if PlayerManager.player.can_dash():
			return dash
		else:
			return null
	return null						
