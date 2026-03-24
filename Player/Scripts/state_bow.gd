class_name State_Bow extends State

const ARROW = preload("res://Interactables/arrow/arrow.tscn")

@onready var idle: State = $"../Idle"

var direction : Vector2 = Vector2.ZERO
var next_state : State = null

func _ready() -> void:
	pass
	
func Enter() -> void:
	var target_pos = player.get_aim_target()
	player.face_target(target_pos)
	player.UpdateAnimation("bow")
	player.animation_player.animation_finished.connect(_on_animation_finished)
	var fire_direction = Vector2.RIGHT.rotated(player.aim_pivot.global_rotation)
	var arrow : Arrow = ARROW.instantiate()
	player.get_parent().add_child(arrow) # Add to world, not as child of player
	var spawn_dist = 58.0
	arrow.global_position = player.aim_pivot.global_position + (fire_direction * spawn_dist)
	arrow.fire(fire_direction)
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
	if Input.is_action_pressed("aim"):
		next_state = $"../Aim"
	else:	
		next_state = idle
	pass
	

							
