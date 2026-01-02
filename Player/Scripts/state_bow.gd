class_name State_Bow extends State

const ARROW = preload("res://Interactables/arrow/arrow.tscn")

@onready var idle: State = $"../Idle"

var direction : Vector2 = Vector2.ZERO
var next_state : State = null

func _ready() -> void:
	pass
	
func Enter() -> void:
	player.UpdateAnimation("bow")
	player.animation_player.animation_finished.connect( _on_animation_finished)
	direction = player.cardinal_direction
	var arrow : Arrow = ARROW.instantiate()
	player.add_sibling(arrow)
	if direction == Vector2.UP:
		arrow.global_position = player.global_position + (direction * 44)
	else:
		arrow.global_position = player.global_position + (direction * 28)
	arrow.fire(direction)
	#await get_tree().process_frame
	pass
	
func Exit() -> void:
	player.animation_player.animation_finished.disconnect( _on_animation_finished)
	next_state = null
	pass
	
func Process(_delta: float) -> State:
	player.velocity = Vector2.ZERO
	return next_state

func Physics(_delta: float) -> State:
	return null	

func HandleInput(_delta: InputEvent) -> State:
	return null		
	
func _on_animation_finished(anim_name : String) -> void:
	next_state = idle
	pass
	

							
