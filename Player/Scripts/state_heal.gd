class_name State_Heal extends State

var next_state : State = null

@onready var idle : State = $"../Idle"
@export var heal_wrath_cost : int = 5
@export var heal_amount : int = 5

func init() -> void:
	pass

func Enter() -> void:
	$"../../Label2".text = "heal"
	$"../../Sprite2D/AttackEffectSprite2".visible = false
	if try_wrath_heal():
		player.UpdateAnimation("healed")
		player.animation_player.animation_finished.connect(state_complete)
	else:
		state_machine.change_state( idle)	
	pass
	
func Exit() -> void:
	pass
	
func Process(_delta: float) -> State:
	Input.start_joy_vibration(0, 0.5, 1.0, 0.1)
	player.velocity = Vector2.ZERO
	return next_state
	
func Physics(_delta: float) -> State:
	return null	

func HandleInput( _event: InputEvent) -> State:
	return null		
	
func state_complete( _a : String) -> void:
	player.animation_player.animation_finished.disconnect( state_complete)
	state_machine.change_state( idle)
	pass	

func try_wrath_heal() -> bool:
	if player.hp >= player.max_hp:
		return false
	if player.consume_wrath(heal_wrath_cost):
		player.hp = min(player.max_hp, player.hp + heal_amount)
		player.update_hp(0)
		return true
	return false
