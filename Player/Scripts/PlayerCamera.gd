#class_name PlayerCamera extends Camera2D
#
#@export var zooom: Vector2 = Vector2(0.75,0.75)
#
## --- Hyper Light Drifter "Look Ahead" Settings ---
#@export_range(0, 1, 0.05) var mouse_influence: float = 0.25 # How much the camera follows the mouse
#@export var max_look_distance: float = 100.0 # Maximum pixels the camera can peek away from player
#@export var look_smoothing: float = 5.0 # How fast the camera shifts (higher = faster)
#
#@export_range(0,1,0.05,"or_greater") var shake_power : float = 0.5 # overall strength of shake
#@export var shake_max_offset : float = 5.0 # maximum shake in pixels
#@export var shake_decay : float = 1.0 # how quickly shake stops
#var shake_trauma : float = 0.0
#var mouse_offset : Vector2 = Vector2.ZERO
	#
#func _ready():
	#zoom = zooom
	#process_callback = CAMERA2D_PROCESS_PHYSICS 
	#LevelManager.TileMapBoundsChanged.connect( UpdateLimits)
	#UpdateLimits(LevelManager.current_tilemap_bounds)
	#PlayerManager.camera_shook.connect( add_camera_shake)
	#pass
#
##func _physics_process(delta: float) -> void:
	##if shake_trauma > 0:
		##shake_trauma = max(shake_trauma - shake_decay * delta, 0)
		##shake()		
	##pass
	##
##func add_camera_shake( val : float) -> void:
	##shake_trauma = val
	##pass	
	##
##func shake() -> void:
	##var amount : float = pow(shake_trauma * shake_power, 2)
	##offset = Vector2( randf_range(-1,1),randf_range(-1,1)) * shake_max_offset * amount
	##pass
	##
##func UpdateLimits( bounds : Array[Vector2]) -> void:
	##if bounds == []:
		##return
	##limit_left = int( bounds[0].x)	
	##limit_top = int( bounds[0].y)	
	##limit_right = int( bounds[1].x)	
	##limit_bottom = int( bounds[1].y)		
	##pass

#class_name PlayerCamera extends Camera2D
#
#@export var zooom: Vector2 = Vector2(0.75, 0.75)
#
## --- Hyper Light Drifter "Look Ahead" Settings ---
#@export_range(0, 1, 0.05) var mouse_influence: float = 0.15 # Reduced for slower feel
#@export var max_look_distance: float = 60.0 # Reduced for slower feel
#@export var look_smoothing: float = 2.0 # Lowered for much slower, smoother movement
#
## --- Shake Settings ---
#@export_range(0, 1, 0.05, "or_greater") var shake_power : float = 0.5 
#@export var shake_max_offset : float = 5.0 
#@export var shake_decay : float = 1.0 
#var shake_trauma : float = 0.0
#
#var mouse_offset : Vector2 = Vector2.ZERO
	#
#func _ready():
	#zoom = zooom
	## Use process for smoother visuals
	#process_callback = CAMERA2D_PROCESS_IDLE 
	#LevelManager.TileMapBoundsChanged.connect(UpdateLimits)
	#UpdateLimits(LevelManager.current_tilemap_bounds)
	#PlayerManager.camera_shook.connect(add_camera_shake)
#
#func _process(delta: float) -> void:
	#update_mouse_look(delta)
	#
	#var shake_vec = Vector2.ZERO
	#if shake_trauma > 0:
		#shake_trauma = max(shake_trauma - shake_decay * delta, 0)
		#shake_vec = get_shake_vector()
	#
	#offset = mouse_offset + shake_vec
	#
#func update_mouse_look(delta: float) -> void:
	#var mouse_pos = get_local_mouse_position()
	#
	## 1. Calculate raw target offset
	#var target_offset = mouse_pos * mouse_influence
	#target_offset = target_offset.limit_length(max_look_distance)
	#
	## 2. CLAMP OFFSET TO TILEMAP LIMITS
	## We calculate the half-size of the visible screen in world pixels
	#var view_size = get_viewport_rect().size * zoom
	#var half_view = view_size / 2.0
	#
	## Calculate how much room the camera has to move before hitting limits
	## limit_left etc. are set by your UpdateLimits function
	#var max_left = (global_position.x - half_view.x) - limit_left
	#var max_right = limit_right - (global_position.x + half_view.x)
	#var max_top = (global_position.y - half_view.y) - limit_top
	#var max_bottom = limit_bottom - (global_position.y + half_view.y)
	#
	## We clamp the target_offset so it can't go further than the available room
	## Note: max_left and max_top should be negative or zero in this context
	#target_offset.x = clamp(target_offset.x, -max_left, max_right)
	#target_offset.y = clamp(target_offset.y, -max_top, max_bottom)
#
	## 3. SMOOTH MOVEMENT
	## Lowered look_smoothing makes the camera move significantly slower
	#mouse_offset = mouse_offset.lerp(target_offset, look_smoothing * delta)
#
#func add_camera_shake(val : float) -> void:
	#shake_trauma = val
	#
#func get_shake_vector() -> Vector2:
	#var amount : float = pow(shake_trauma * shake_power, 2)
	#return Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_max_offset * amount
	#
#func UpdateLimits(bounds : Array[Vector2]) -> void:
	#if bounds == [] or bounds.size() < 2: return
	#limit_left = int(bounds[0].x)	
	#limit_top = int(bounds[0].y)	
	#limit_right = int(bounds[1].x)	
	#limit_bottom = int(bounds[1].y)

class_name PlayerCamera extends Camera2D

@export var zooom: Vector2 = Vector2(0.75, 0.75)
@export_range(0, 1, 0.05) var mouse_influence: float = 0.2
@export var max_look_distance: float = 60.0
@export var look_smoothing: float = 2.0 # Lower = Slower/Smoother

@export_group("Shake Settings")
@export_range(0, 1, 0.05, "or_greater") var shake_power : float = 0.5 
@export var shake_max_offset : float = 5.0 
@export var shake_decay : float = 1.0 
var shake_trauma : float = 0.0

func _ready():
	zoom = zooom
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
	
	var target_lean: Vector2 = Vector2.ZERO
	var p = PlayerManager.player 
	var is_aiming = p.state_machine.current_state is State_Aim
	
	if not is_aiming:
		if p.is_using_controller:
			# Don't use right stick for camera - only use movement direction
			var joy_dir = p.direction
			if PlayerManager.player.stick_intensity >= 0.9:
				target_lean = joy_dir * max_look_distance
		else:
			# 4. MOUSE LEAN: (Your existing logic)
			target_lean = get_local_mouse_position() * mouse_influence
			target_lean = target_lean.limit_length(max_look_distance)
		
		# 5. Smoothly interpolate LOCAL POSITION (The lerp handles the switch perfectly)
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
