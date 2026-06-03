class_name PlayerCamera extends Camera2D

@export var zooom: Vector2 = Vector2(0.75, 0.75)
@export_range(0, 1, 0.05) var mouse_influence: float = 0.2
@export var max_look_distance: float = 60.0
@export var look_smoothing: float = 2.0 # Lower = Slower/Smoother

@export_group("Limit Transitions")
## Duration for smooth limit transitions (in seconds)
@export var limit_transition_duration: float = 0.5
## Temporary smoothing multiplier during limit transitions
@export var transition_smoothing_boost: float = 0.5

@export_group("Shake Settings")
@export_range(0, 1, 0.05, "or_greater") var shake_power : float = 0.5 
@export var shake_max_offset : float = 5.0 
@export var shake_decay : float = 1.0 
var shake_trauma : float = 0.0

# NEW: Smooth limit transition variables
var _is_transitioning_limits: bool = false
var _transition_timer: float = 0.0
var _start_limits: Array[int] = [0, 0, 0, 0]  # left, top, right, bottom
var _target_limits: Array[int] = [0, 0, 0, 0]
var _original_smoothing: float = 2.0

func _ready():
	zoom = zooom
	_original_smoothing = look_smoothing
	# Use IDLE process for smooth mouse following
	process_callback = CAMERA2D_PROCESS_IDLE
	
	# Connect signals
	LevelManager.TileMapBoundsChanged.connect(UpdateLimits)
	UpdateLimits(LevelManager.current_tilemap_bounds)
	PlayerManager.camera_shook.connect(add_camera_shake)
	LevelManager.level_loaded.connect(_on_scene_transition)
	
	# Transition Fix: Force camera to player position immediately
	reset_camera_position()

func _process(delta: float) -> void:
	if _is_transitioning_limits:
		_update_limit_transition(delta)
	
	var target_lean: Vector2 = Vector2.ZERO
	var p = PlayerManager.player 
	var is_aiming = p.state_machine.current_state is State_Aim
	if not is_aiming:
		if p.is_using_controller:
			var joy_dir = p.direction
			if PlayerManager.player.stick_intensity >= 0.9:
				target_lean = joy_dir * max_look_distance
		else:
			target_lean = get_local_mouse_position() * mouse_influence
			target_lean = target_lean.limit_length(max_look_distance)
		position = position.lerp(target_lean, look_smoothing * delta)
	if shake_trauma > 0:
		shake_trauma = max(shake_trauma - shake_decay * delta, 0)
		offset = get_shake_vector()
	else:
		offset = Vector2.ZERO

func reset_camera_position() -> void:
	# Call this to snap camera to player (used during scene entry)
	position = Vector2.ZERO
	force_update_scroll() # Updates camera internals immediately

func _on_scene_transition() -> void:
	reset_smoothing.call_deferred()
	pass

func add_camera_shake(val : float) -> void:
	shake_trauma = val
	
func get_shake_vector() -> Vector2:
	var amount : float = pow(shake_trauma * shake_power, 2)
	return Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_max_offset * amount
	
func UpdateLimits(bounds : Array[Vector2]) -> void:
	if bounds == [] or bounds.size() < 2: return
	limit_left = int(bounds[0].x)	
	limit_top = int(bounds[0].y)	
	limit_right = int(bounds[1].x)	
	limit_bottom = int(bounds[1].y)

func set_limits_smooth(new_limits: Array[int]) -> void:
	"""Smoothly transition to new camera limits"""
	if new_limits.size() != 4:
		return
	
	# Store current limits as start
	_start_limits = [limit_left, limit_top, limit_right, limit_bottom]
	_target_limits = new_limits.duplicate()
	
	# Start transition
	_is_transitioning_limits = true
	_transition_timer = 0.0
	
	# Boost smoothing during transition for smoother camera movement
	look_smoothing = _original_smoothing * transition_smoothing_boost
	
	print("Starting smooth limit transition: ", _start_limits, " -> ", _target_limits)

# NEW: Update limit transition
func _update_limit_transition(delta: float) -> void:
	_transition_timer += delta
	var progress = min(_transition_timer / limit_transition_duration, 1.0)
	
	# Use ease-out for smooth deceleration
	var eased_progress = ease(progress, -2.0)  # Ease out
	
	# Lerp each limit
	limit_left = int(lerp(float(_start_limits[0]), float(_target_limits[0]), eased_progress))
	limit_top = int(lerp(float(_start_limits[1]), float(_target_limits[1]), eased_progress))
	limit_right = int(lerp(float(_start_limits[2]), float(_target_limits[2]), eased_progress))
	limit_bottom = int(lerp(float(_start_limits[3]), float(_target_limits[3]), eased_progress))
	
	# End transition
	if progress >= 1.0:
		_is_transitioning_limits = false
		# Restore original smoothing
		look_smoothing = _original_smoothing
		print("Limit transition completed")

# NEW: Instant limit update (for when you need it)
func set_limits_instant(new_limits: Array[int]) -> void:
	"""Instantly set camera limits without transition"""
	if new_limits.size() != 4:
		return
	
	limit_left = new_limits[0]
	limit_top = new_limits[1]
	limit_right = new_limits[2]
	limit_bottom = new_limits[3]
	
	_is_transitioning_limits = false

# NEW: Get current limits as array
func get_current_limits() -> Array[int]:
	return [limit_left, limit_top, limit_right, limit_bottom]	
