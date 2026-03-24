class_name State_Aim extends State

@export var controller_cursor_speed: float = 400.0
@onready var idle: State = $"../Idle"

var virtual_cursor_pos: Vector2 = Vector2.ZERO

func Enter() -> void:
	print("ENTERING AIM STATE")
	player.velocity = Vector2.ZERO
	player.aim_sprite.visible = true
	$"../../CursorOverlay".visible = true 
	player.UpdateAnimation("idle")

func Exit() -> void:
	print("EXITING AIM STATE")
	player.aim_sprite.visible = false
	$"../../CursorOverlay".visible = false 

func Process(delta: float) -> State:
	if not Input.is_action_pressed("aim"):
		return idle
	
	# THIS WAS MISSING - actually move the cursor!
	update_controller_cursor(delta)
	
	return null

func update_controller_cursor(delta: float) -> void:
	var input_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	
	if input_dir.length() > 0.2:
		player.virtual_cursor_pos += input_dir * controller_cursor_speed * delta
	
	var screen_size = get_viewport().get_visible_rect().size
	player.virtual_cursor_pos.x = clamp(player.virtual_cursor_pos.x, 0, screen_size.x)
	player.virtual_cursor_pos.y = clamp(player.virtual_cursor_pos.y, 0, screen_size.y)

func HandleInput(_event: InputEvent) -> State:
	var trigger_strength = Input.get_action_strength("ability")
	if trigger_strength > 0.7 and player.arrow_count > 0:
		print("ENTERING BOW STATE")
		return $"../Bow"
	return null
