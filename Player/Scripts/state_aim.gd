class_name State_Aim extends State

@onready var idle: State = $"../Idle"
@onready var aim_sprite: Sprite2D = $"../../AimPivot/AimSprite"
@export var rotation_speed = 10.0
@export var fire_cooldown: float = 0.5  # seconds between shots
const ARROW = preload("res://Interactables/arrow/arrow.tscn")

var cooldown_timer: float = 0.0
var already_firing: bool = false  # prevents holding trigger from spamming

func Enter() -> void:
	player.is_using_controller = true
	player.aim_sprite_visible = true
	$"../../AimPivot/AimSprite".visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	player.velocity = Vector2.ZERO
	player.UpdateAnimation("idle")
	cooldown_timer = 0.0
	already_firing = false

func Exit() -> void:
	player.is_using_controller = false
	player.aim_sprite_visible = false
	$"../../AimPivot/AimSprite".visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	already_firing = false
	
func Process(delta: float) -> State:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		
	var trigger_strength = Input.get_action_strength("ability_controller")
	if trigger_strength < 0.2:
		already_firing = false	
		
	var v = Vector2(
	Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
	Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	if v.length() > 0.2:
		var target_angle = v.angle()
		$"../../AimPivot/AimSprite".rotation = lerp_angle($"../../AimPivot/AimSprite".rotation, target_angle, rotation_speed * delta)
	
	var aim_direction = Vector2.RIGHT.rotated(aim_sprite.rotation)
	var direction_id = posmod(int(round(aim_direction.angle() / TAU * player.DIR_4.size())), player.DIR_4.size())
	var new_cardinal = player.DIR_4[direction_id]

	if new_cardinal != player.cardinal_direction:
		player.cardinal_direction = new_cardinal
		player.DirectionChanged.emit(new_cardinal)
		player.sprite.scale.x = -1 if new_cardinal == Vector2.LEFT else 1
	
	player.UpdateAnimation("bow")
	
	if Input.is_action_just_released("aim"):
		return $"../Idle"
	return null

func HandleInput(_event: InputEvent) -> State:
	var trigger_strength = Input.get_action_strength("ability_controller")
	if trigger_strength < 0.2 or player.arrow_count <= 0 or cooldown_timer > 0.0 or already_firing:
		return null
	already_firing = true
	cooldown_timer = fire_cooldown
	player.arrow_count -= 1
	var aim_target_pos: Vector2
	aim_target_pos = $"../../AimPivot/AimSprite".global_position
	player.face_target(aim_target_pos)
	player.UpdateAnimation("bow")
	if not 	player.animation_player.animation_finished.is_connected(_on_animation_finished):
		player.animation_player.animation_finished.connect(_on_animation_finished)
	var fire_direction: Vector2
	fire_direction = Vector2.RIGHT.rotated($"../../AimPivot/AimSprite".global_rotation)
	var arrow: Arrow = ARROW.instantiate()
	player.get_parent().add_child(arrow)  # Add to world, not as child of player
	var spawn_dist: float = 58.0
	arrow.global_position = player.global_position + (fire_direction * spawn_dist)
	arrow.fire(fire_direction)
	return null

func _on_animation_finished(anim_name: String) -> void:
	player.animation_player.animation_finished.disconnect(_on_animation_finished)	
