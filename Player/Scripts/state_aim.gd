class_name State_Aim extends State

@export var controller_cursor_speed: float = 500.0  # Reduced from 800
@onready var idle: State = $"../Idle"

# Store virtual cursor position for smooth, stable tracking
var virtual_cursor_pos: Vector2 = Vector2.ZERO


func Enter() -> void:
	# 1. Stop movement
	player.velocity = Vector2.ZERO
	# 2. Force visuals on
	player.aim_sprite.visible = true
	$"../../CursorOverlay".visible = true 
	# Initialize virtual cursor to current mouse position
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

	# 2. If using controller, update the VIRTUAL cursor position (don't warp yet)
	if player.is_using_controller:
		update_controller_cursor(delta)
		# NOW warp the mouse ONCE to match virtual position
		get_viewport().warp_mouse(virtual_cursor_pos)
	
	# 3. Ensure the character always faces the cursor while aiming
	player.face_target(player.get_global_mouse_position())
	
	# 4. Keep the aim pivot updated
	player.update_aim_pivot(delta)
	
	return null

func update_controller_cursor(delta: float) -> void:
	# Get Left Stick input
	var input_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	).normalized()
	
	# Only move if stick is pushed beyond deadzone
	if input_dir.length() > 0.15:
		# Smoothly update virtual cursor position
		virtual_cursor_pos += input_dir * controller_cursor_speed * delta
		
		# Clamp to screen boundaries
		var screen_size = get_viewport().get_visible_rect().size
		virtual_cursor_pos.x = clamp(virtual_cursor_pos.x, 0, screen_size.x)
		virtual_cursor_pos.y = clamp(virtual_cursor_pos.y, 0, screen_size.y)
