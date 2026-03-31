extends Node2D

@export var follow_speed: float = 15.0
@export var offset_from_cursor: float = 20.0
@export var min_visible_distance: float = 10.0

var current_distance: float = 0.0

func _process(delta):
	if PlayerManager.player.is_using_controller:
		visible = false
	else:	
		var player = get_parent()
		var player_pos = player.global_position
		var mouse_pos = get_global_mouse_position()
		
		var direction_vec = mouse_pos - player_pos
		var distance = direction_vec.length()
		
		if distance < min_visible_distance:
			visible = false
			return
		visible = true
		
		var dir = direction_vec.normalized()
		
		var target_distance = max(0.0, distance - offset_from_cursor)
		current_distance = lerp(current_distance, target_distance, follow_speed * delta)
		
		position = dir * current_distance
		
		# Rotate sprite to face cursor direction
		rotation = dir.angle()
