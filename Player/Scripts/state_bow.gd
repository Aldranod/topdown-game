class_name State_Bow extends State

const ARROW = preload("res://Interactables/arrow/wrath_arrow.tscn")

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

func spawn_arrow() -> void:
	if state_machine.current_state == $"../Aim":
		$"../Aim".release_arrow()   # kontroler: strzał z State_Aim, na klatce animacji
		return
	if state_machine.current_state != self:
		return
	var aim_target_pos: Vector2 = PlayerManager.player.get_global_mouse_position() + Vector2(0,5)
	player.face_target(aim_target_pos)
	var pivot_pos : Vector2 = $"../../AimPivot".global_position
	var fire_direction : Vector2 = (aim_target_pos - pivot_pos).normalized()
	if not player.fire_arrow(ARROW, pivot_pos, fire_direction):
		player.add_wrath(player.player_abilities.shoot_wrath_cost)   # zwrot kosztu, strzał zablokowany przez ścianę
							
