class_name State_Walk extends State

@export var move_speed : float = 100.0
@onready var idle : State = $"../Idle"	
@onready var attack: State = $"../Attack"
@onready var dash: State = $"../Dash"
@onready var second_attack: State_SecondAttack = $"../SecondAttack"
@onready var third_attack: State_ThirdAttack = $"../ThirdAttack"

@onready var run: State = $"../Run"

func Enter() -> void:
	player.UpdateAnimation("walk")
	pass
	
func Exit() -> void:
	pass
	
func Process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle
	# If stick intensity is high, switch to run
	if player.stick_intensity >= 0.7 and not Input.is_action_pressed("walk"):
		return run
	player. velocity = player.direction * move_speed
	if player.SetDirection():
		player.UpdateAnimation("walk")
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
	elif _event.is_action_pressed("interact"):
		PlayerManager.interact()
	elif _event.is_action_pressed("dash"):
		if PlayerManager.player.can_dash():
			return dash
		else:
			return null
	return null		
				
