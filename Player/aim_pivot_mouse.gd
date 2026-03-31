extends Node2D

@export var follow_speed: float = 15.0
@export var offset_from_cursor: float = 20.0
@export var min_visible_distance: float = 10.0

var current_distance: float = 0.0

func _process(delta):
	var player = get_parent()
	var player_pos = player.global_position
	var mouse_pos = get_global_mouse_position()
	
	var direction_vec = mouse_pos - player_pos
	var distance = direction_vec.length()

	# Hide if too close
	if distance < min_visible_distance:
		visible = false
		return
	visible = true
	
	var dir = direction_vec.normalized()
	
	# Target distance = slightly before cursor
	var target_distance = max(0.0, distance - offset_from_cursor)
	
	# Smooth ONLY the distance (not position!)
	current_distance = lerp(current_distance, target_distance, follow_speed * delta)
	
	# Rebuild position from player every frame → no drift
	position = dir * current_distance
