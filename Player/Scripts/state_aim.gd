class_name State_Aim extends State

@export var controller_cursor_speed: float = 800.0
@onready var idle: State = $"../Idle"

func Enter() -> void:
	# 1. Stop movement
	player.velocity = Vector2.ZERO
	# 2. Force visuals on
	player.aim_sprite.visible = true
	$"../../CursorOverlay".visible = true 
	# Assuming CursorManager is your Autoload CanvasLayer
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

	# 2. If using controller, move the mouse cursor with the Left Stick
	if player.is_using_controller:
		update_controller_mouse_emulation(delta)
	
	# 3. Ensure the character always faces the cursor while aiming
	player.face_target(player.get_global_mouse_position())
	
	# 4. Keep the aim pivot updated
	player.update_aim_pivot(delta)
	
	return null

func update_controller_mouse_emulation(delta: float) -> void:
	# Get Left Stick input (The same one used for movement)
	var input_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	
	if input_dir.length() > 0.1:
		# Get current screen mouse position
		var current_mouse_pos = get_viewport().get_mouse_position()
		
		# Calculate new position
		var new_mouse_pos = current_mouse_pos + (input_dir * controller_cursor_speed * delta)
		
		# Clamp to screen boundaries so the cursor doesn't disappear
		var screen_size = get_viewport().get_visible_rect().size
		new_mouse_pos.x = clamp(new_mouse_pos.x, 0, screen_size.x)
		new_mouse_pos.y = clamp(new_mouse_pos.y, 0, screen_size.y)
		
		# WARP the hardware cursor to the new position
		get_viewport().warp_mouse(new_mouse_pos)
