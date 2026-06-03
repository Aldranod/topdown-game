class_name CameraLimiter extends Area2D
## Camera Limiter Node
## Modifies camera limits when player enters the collision shape area.
## When player exits, camera limits return to previous state.

## The collision layer that the player is on
@export_flags_2d_physics var player_collision_layer: int = 1

## Whether to use smooth transitions when changing limits
@export var use_smooth_transition: bool = true

## Optional debug visualization
@export var debug_draw: bool = false
@export var debug_color: Color = Color(0.2, 0.8, 0.2, 0.3)

# Internal state
var _previous_bounds: Array[Vector2] = []
var _is_player_inside: bool = false
var _collision_shape: CollisionShape2D = null

func _ready() -> void:
	# Find the CollisionShape2D child
	_collision_shape = _find_collision_shape()
	
	if _collision_shape == null:
		push_error("CameraLimiter: No CollisionShape2D found as child!")
		return
	
	if not _collision_shape.shape is RectangleShape2D:
		push_warning("CameraLimiter: CollisionShape2D should use RectangleShape2D for best results")
	
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set up collision detection
	monitoring = true
	monitorable = false

func _find_collision_shape() -> CollisionShape2D:
	"""Find the first CollisionShape2D child"""
	for child in get_children():
		if child is CollisionShape2D:
			return child
	return null

func _on_body_entered(body: Node2D) -> void:
	"""Called when a body enters the limiter area"""
	# Check if it's the player
	if not _is_player(body):
		return
	
	if _is_player_inside:
		return  # Already inside
	
	_is_player_inside = true
	
	# Store current bounds before changing
	_previous_bounds = LevelManager.current_tilemap_bounds.duplicate()
	
	# Calculate new bounds from collision shape
	var new_bounds = _calculate_bounds_from_shape()
	
	if new_bounds.size() == 2:
		# Change the camera limits through LevelManager
		LevelManager.ChangeTilemapBounds(new_bounds)
		
		if debug_draw:
			print("CameraLimiter: Player entered - New bounds: ", new_bounds)

func _on_body_exited(body: Node2D) -> void:
	"""Called when a body exits the limiter area"""
	# Check if it's the player
	if not _is_player(body):
		return
	
	if not _is_player_inside:
		return  # Already outside
	
	_is_player_inside = false
	
	# Restore previous bounds
	if _previous_bounds.size() == 2:
		LevelManager.ChangeTilemapBounds(_previous_bounds)
		
		if debug_draw:
			print("CameraLimiter: Player exited - Restored bounds: ", _previous_bounds)

func _is_player(body: Node2D) -> bool:
	"""Check if the body is the player"""
	# Method 1: Check if body is in the player collision layer
	if body.collision_layer & player_collision_layer:
		return true
	
	# Method 2: Check by class name or node name
	if body.name == "Player" or body is CharacterBody2D:
		return true
	
	return false

func _calculate_bounds_from_shape() -> Array[Vector2]:
	"""Calculate camera bounds from the collision shape"""
	var bounds: Array[Vector2] = []
	
	if _collision_shape == null or _collision_shape.shape == null:
		return bounds
	
	var shape = _collision_shape.shape
	var shape_position = _collision_shape.global_position
	
	if shape is RectangleShape2D:
		var rect_shape = shape as RectangleShape2D
		var extents = rect_shape.size / 2.0
		
		# Calculate top-left and bottom-right corners
		var top_left = shape_position - extents
		var bottom_right = shape_position + extents
		
		bounds.append(top_left)
		bounds.append(bottom_right)
	
	elif shape is CircleShape2D:
		var circle_shape = shape as CircleShape2D
		var radius = circle_shape.radius
		
		# Create a square bounding box from the circle
		var top_left = shape_position - Vector2(radius, radius)
		var bottom_right = shape_position + Vector2(radius, radius)
		
		bounds.append(top_left)
		bounds.append(bottom_right)
	
	elif shape is CapsuleShape2D:
		var capsule_shape = shape as CapsuleShape2D
		var radius = capsule_shape.radius
		var height = capsule_shape.height
		
		# Create bounding box
		var extents = Vector2(radius, height / 2.0)
		var top_left = shape_position - extents
		var bottom_right = shape_position + extents
		
		bounds.append(top_left)
		bounds.append(bottom_right)
	
	else:
		# For other shapes, try to get the bounding rect
		push_warning("CameraLimiter: Unsupported shape type, using approximate bounds")
		# Fallback: use a default size
		var default_size = Vector2(500, 500)
		bounds.append(shape_position - default_size / 2.0)
		bounds.append(shape_position + default_size / 2.0)
	
	return bounds

func _draw() -> void:
	"""Debug visualization of the limiter area"""
	if not debug_draw or _collision_shape == null:
		return
	
	var shape = _collision_shape.shape
	if shape is RectangleShape2D:
		var rect_shape = shape as RectangleShape2D
		var rect_size = rect_shape.size
		var offset = _collision_shape.position
		
		# Draw the rectangle
		draw_rect(
			Rect2(offset - rect_size / 2.0, rect_size),
			debug_color,
			true
		)
		
		# Draw border
		draw_rect(
			Rect2(offset - rect_size / 2.0, rect_size),
			debug_color * 2.0,
			false,
			2.0
		)

func _process(_delta: float) -> void:
	if debug_draw:
		queue_redraw()

## Public API for manual control
func activate_limits() -> void:
	"""Manually activate the camera limits (as if player entered)"""
	if _is_player_inside:
		return
	
	_previous_bounds = LevelManager.current_tilemap_bounds.duplicate()
	var new_bounds = _calculate_bounds_from_shape()
	
	if new_bounds.size() == 2:
		LevelManager.ChangeTilemapBounds(new_bounds)
		_is_player_inside = true

func deactivate_limits() -> void:
	"""Manually deactivate the camera limits (as if player exited)"""
	if not _is_player_inside:
		return
	
	if _previous_bounds.size() == 2:
		LevelManager.ChangeTilemapBounds(_previous_bounds)
		_is_player_inside = false

func get_limiter_bounds() -> Array[Vector2]:
	"""Get the bounds that this limiter would set"""
	return _calculate_bounds_from_shape()
