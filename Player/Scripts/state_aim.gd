class_name State_Aim extends State

@export var controller_cursor_speed: float = 500.0
@onready var idle: State = $"../Idle"

var virtual_cursor_pos: Vector2 = Vector2.ZERO


func Enter() -> void:
	player.velocity = Vector2.ZERO
	player.aim_sprite.visible = true
	$"../../CursorOverlay".visible = true 
	virtual_cursor_pos = get_viewport().get_mouse_position()
	player.UpdateAnimation("idle") 

func Exit() -> void:
	if player.is_using_controller:
		player.aim_sprite.visible = false
		$"../../CursorOverlay".visible = false 

func Process(delta: float) -> State:
	if not Input.is_action_pressed("aim"):
		return idle

	if player.is_using_controller:
		update_controller_cursor(delta)
		update_aim_sprite_position(delta)
	
	player.face_target(virtual_cursor_pos)
	player.update_aim_pivot(delta)
	
	return null

func update_controller_cursor(delta: float) -> void:
	var input_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	).normalized()
	
	if input_dir.length() > 0.15:
		virtual_cursor_pos += input_dir * controller_cursor_speed * delta
	
	var screen_size = get_viewport().get_visible_rect().size
	virtual_cursor_pos.x = clamp(virtual_cursor_pos.x, 0, screen_size.x)
	virtual_cursor_pos.y = clamp(virtual_cursor_pos.y, 0, screen_size.y)

func update_aim_sprite_position(delta: float) -> void:
	var vec_to_cursor = virtual_cursor_pos - player.aim_pivot.global_position
	var target_x = max(0.0, vec_to_cursor.length() - player.cursor_gap)
	player.aim_sprite.position.x = lerp(player.aim_sprite.position.x, target_x, player.aim_smoothness * delta)
