class_name State_Aim extends State

@export var controller_cursor_speed: float = 500.0
@onready var idle: State = $"../Idle"

var virtual_cursor_pos: Vector2 = Vector2.ZERO
var is_warping: bool = false  # Flag to prevent input event from triggering


func Enter() -> void:
	# 1. Stop movement
	player.velocity = Vector2.ZERO
	# 2. Force visuals on
	player.aim_sprite.visible = true
	$"../../CursorOverlay".visible = true 
	virtual_cursor_pos = get_viewport().get_mouse_position()
	# 3. Play an idle or aiming animation
	player.UpdateAnimation("idle") 

func Exit() -> void:
	# If we are using a controller, hide the cursor again upon leaving
	if player.is_using_controller:
		player.aim_sprite.visible = false
		$"../../CursorOverlay".visible = false 

func Process(delta: float) -> State:
	# 1. If "aim" button is released, return to idle
	if not Input.is_action_pressed("aim"):
		return idle

	# 2. If using controller, update the VIRTUAL cursor position
	if player.is_using_controller:
		update_controller_cursor(delta)
		# Set flag before warping to prevent _unhandled_input from toggling is_using_controller
		is_warping = true
		get_viewport().warp_mouse(virtual_cursor_pos)
		is_warping = false
	
	# 3. Ensure the character always faces the cursor while aiming
	player.face_target(player.get_global_mouse_position())
	
	# 4. Keep the aim pivot updated
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
