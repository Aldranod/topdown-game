extends Node2D

const CURSOR_SPEED: float = 500.0
const DEADZONE: float = 0.2

@onready var cursor_sprite: Sprite2D = $MainCursor
var cursor_pos: Vector2

func _ready() -> void:
	cursor_pos = get_viewport().get_visible_rect().size / 2

func _process(delta: float) -> void:
	var p = PlayerManager.player
		
	if p.is_using_controller:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		var in_aim_state = p.state_machine.current_state is State_Aim
		if in_aim_state:
			var move = Vector2(
				Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
				Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
			)

			if move.length() < DEADZONE:
				move = Vector2.ZERO
			else:
				move = (move - move.normalized() * DEADZONE) / (1.0 - DEADZONE)
			cursor_pos += move * CURSOR_SPEED * delta
			cursor_pos = cursor_pos.clamp(Vector2.ZERO, get_viewport().get_visible_rect().size)
		
		cursor_sprite.position = get_viewport().canvas_transform.affine_inverse() * cursor_pos
		cursor_sprite.visible = in_aim_state
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cursor_pos = get_viewport().get_mouse_position()
		cursor_sprite.global_position = get_viewport().canvas_transform.affine_inverse() * cursor_pos
		cursor_sprite.visible = false
	p.virtual_cursor_pos = cursor_pos
	print("cursor_sprite.global_position: ", cursor_sprite.global_position)
	print("p.aim_sprite.global_position: ", p.aim_sprite.global_position)
	print("p.aim_pivot.global_position: ", p.aim_pivot.global_position)
	print("---")
