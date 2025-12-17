class_name State extends Node

# Store reference to the player that this state belongs to
static var player: Player
static var state_machine : PlayerStateMachine

func _ready():
	pass
	
func init() -> void:
	pass	
	
func Enter() -> void:
	pass
	
func Exit() -> void:
	pass
	
func Process(_delta: float) -> State:
	return null

func Physics(_delta: float) -> State:
	return null	

func HandleInput(_delta: InputEvent) -> State:
	return null						
