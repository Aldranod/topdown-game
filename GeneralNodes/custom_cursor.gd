extends Node2D

@export var offset: Vector2 = Vector2(10, 10) # The "shadow" distance
@export var lerp_speed: float = 0.0 # Set to 0 for instant, or e.g. 20 for "lazy" follow

@onready var main_cursor = $MainCursor

func _ready() -> void:
	# 1. Hide the system hardware mouse
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	# 2. Get the mouse position relative to the screen (Viewport)
	var p = PlayerManager.player
	if not p: return

	# Determine if we should be visible
	var in_aim_state = p.state_machine.current_state is State_Aim
	
	if p.is_using_controller:
		# Only show on controller if we are actively in the Aim State
		visible = in_aim_state
	else:
		# Always show if using mouse/keyboard
		visible = true
	var mouse_pos = get_viewport().get_mouse_position()
	
	# 3. Update Main Cursor
	main_cursor.global_position = mouse_pos
	
