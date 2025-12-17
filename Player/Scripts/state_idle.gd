class_name State_Idle extends State

@onready var walk: State = $"../Walk"	
@onready var attack: State = $"../Attack"
@onready var dash: State = $"../Dash"
@onready var second_attack: State = $"../SecondAttack"

func Enter() -> void:
	player.UpdateAnimation("idle")
	pass
	
func Exit() -> void:
	pass
	
func Process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null

func Physics(_delta: float) -> State:
	return null	

func HandleInput( _event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		if PlayerManager.player.combo_window_open:
			return second_attack
		else:	
			return attack
	elif _event.is_action_pressed("interact"):
		PlayerManager.interact()
	elif _event.is_action_pressed("dash"):
		if PlayerManager.player.can_dash():
			return dash
		else:
			return null
	return null						
