extends Node2D

@export var offset: Vector2 = Vector2(10, 10)
@export var lerp_speed: float = 0.0  # Set to 0 for instant

@onready var main_cursor = $MainCursor

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	var p = PlayerManager.player
	if not p: return

	var in_aim_state = p.state_machine.current_state is State_Aim
	
	if p.is_using_controller:
		visible = in_aim_state
	else:
		visible = true
	
	# Get cursor position from virtual cursor if aiming with controller
	var cursor_pos: Vector2
	if p.is_using_controller and in_aim_state:
		var aim_state = p.state_machine.current_state as State_Aim
		cursor_pos = aim_state.virtual_cursor_pos
	else:
		cursor_pos = get_viewport().get_mouse_position()
	
	# Update Main Cursor
	main_cursor.global_position = cursor_pos
