class_name State_Bow extends State

const ARROW = preload("res://Interactables/arrow/arrow.tscn")

@onready var idle: State = $"../Idle"

var direction : Vector2 = Vector2.ZERO
var next_state : State = null
@onready var aim_sprite: Sprite2D = $"../../AimPivot/AimSprite"
@export var sprite_visual_offset: Vector2 = Vector2(0, 16)

func _ready() -> void:
	pass
	
func Enter() -> void:
	var aim_target_pos: Vector2 = player.get_global_mouse_position()
	player.face_target(aim_target_pos)
	player.UpdateAnimation("bow")	
	player.animation_player.animation_finished.connect(_on_animation_finished)
	
	#var fire_direction: Vector2
	#fire_direction = (aim_target_pos - player.global_position).normalized()
	
	var pivot_pos = $"../../AimPivot".global_position
	var fire_direction = (aim_target_pos - pivot_pos).normalized()
	
	var arrow: Arrow = ARROW.instantiate()
	player.get_parent().add_child(arrow)  # Add to world, not as child of player
	var spawn_dist: float = 48.0
	#arrow.global_position = player.global_position + (fire_direction * spawn_dist)
	arrow.global_position = pivot_pos + (fire_direction * spawn_dist)
	#arrow.global_position = pivot_pos + (fire_direction * spawn_dist)
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
	

							
