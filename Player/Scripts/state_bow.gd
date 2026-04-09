class_name State_Bow extends State

const ARROW = preload("res://Interactables/arrow/arrow.tscn")

@onready var idle: State = $"../Idle"
var direction : Vector2 = Vector2.ZERO
var next_state : State = null
@onready var aim_sprite: Sprite2D = $"../../AimPivot/AimSprite"

func _ready() -> void:
	
	pass
	
func Enter() -> void:
	$"../../Label2".text = "bow"	
	var aim_target_pos: Vector2 = PlayerManager.player.get_global_mouse_position() + Vector2(0,5)
	player.face_target(aim_target_pos)
	player.UpdateAnimation("bow")	
	player.animation_player.animation_finished.connect(_on_animation_finished)
	var pivot_pos = $"../../AimPivot".global_position
	var fire_direction = (aim_target_pos - pivot_pos).normalized()
	print(fire_direction)
	var arrow: Arrow = ARROW.instantiate()
	player.get_parent().add_child(arrow) 
	var spawn_dist: float = 48.0
	arrow.global_position = pivot_pos + (fire_direction * spawn_dist)
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
	

							
