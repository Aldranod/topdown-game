#class_name State_Aim extends State
#
#@export var controller_cursor_speed: float = 300.0
#@onready var idle: State = $"../Idle"
#
#var virtual_cursor_pos: Vector2 = Vector2.ZERO
#
#func Enter() -> void:
	#player.velocity = Vector2.ZERO
	#player.aim_sprite.visible = true
	#$"../../CursorOverlay".visible = true 
	#virtual_cursor_pos = get_viewport().get_mouse_position()
	#player.UpdateAnimation("idle") 
#
#func Exit() -> void:
	#if player.is_using_controller:
		#player.aim_sprite.visible = false
		#$"../../CursorOverlay".visible = false 
#
#func Process(delta: float) -> State:
	#if not Input.is_action_pressed("aim"):
		#return idle
#
	#if player.is_using_controller:
		#update_controller_cursor(delta)
		## Only face target, don't call update_aim_pivot
		#player.face_target(virtual_cursor_pos)
	#else:
		## For mouse, use normal logic
		#player.face_target(player.get_global_mouse_position())
		#player.update_aim_pivot(delta)
	#
	#return null
#
#func update_controller_cursor(delta: float) -> void:
	#var input_dir = Vector2(
		#Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		#Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	#)
	#
	#if input_dir.length() > 0.2:
		#virtual_cursor_pos += input_dir * controller_cursor_speed * delta
	#
	#var screen_size = get_viewport().get_visible_rect().size
	#virtual_cursor_pos.x = clamp(virtual_cursor_pos.x, 0, screen_size.x)
	#virtual_cursor_pos.y = clamp(virtual_cursor_pos.y, 0, screen_size.y)
#
#func HandleInput(_event: InputEvent) -> State:
	#if _event.is_action_pressed("ability"):
		#if player.arrow_count <=0:
			#return
		#else:	
			#player.arrow_count -= 1
			#return $"../Bow"
	#return null		

class_name State_Aim extends State

@export var controller_cursor_speed: float = 400.0
@onready var idle: State = $"../Idle"

# This stores the screen pixels (e.g., 0 to 1920)
var virtual_cursor_pos: Vector2 = Vector2.ZERO
const ARROW = preload("res://Interactables/arrow/arrow.tscn")
var next_state : State = null

func Enter() -> void:
	var screen_player_pos = get_viewport().canvas_transform * player.global_position
	player.virtual_cursor_pos = screen_player_pos
	print("ENTERING AIM STATE")
	player.velocity = Vector2.ZERO
	player.aim_sprite.visible = true
	$"../../CursorOverlay".visible = true 
	player.UpdateAnimation("idle")

func Exit() -> void:
	# Hide visuals when leaving the state
	print("EXITING AIM STATE")
	player.aim_sprite.visible = false
	$"../../CursorOverlay".visible = false 

func Process(delta: float) -> State:
	if not Input.is_action_pressed("aim"):
		return idle
	
	return null

func update_controller_cursor(delta: float) -> void:
	var input_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	
	if input_dir.length() > 0.2:
		virtual_cursor_pos += input_dir * controller_cursor_speed * delta
	
	# Clamp to screen boundaries
	var screen_size = get_viewport().get_visible_rect().size
	virtual_cursor_pos.x = clamp(virtual_cursor_pos.x, 0, screen_size.x)
	virtual_cursor_pos.y = clamp(virtual_cursor_pos.y, 0, screen_size.y)

#func HandleInput(_event: InputEvent) -> State:
	#if _event.is_action_pressed("ability"):
		#print("shoot")
		#if player.arrow_count <= 0:
			#return null
		#else:
			#player.arrow_count -= 1
			#var target_pos: Vector2
			#if player.is_using_controller:
				#target_pos = player.get_canvas_transform().affine_inverse() * virtual_cursor_pos
			#else:
				#target_pos = player.get_global_mouse_position()
			#
			##var target_pos = player.get_global_mouse_position()
			##player.face_target(target_pos)
			#player.UpdateAnimation("bow")
			#player.animation_player.animation_finished.connect(_on_animation_finished)
			#var fire_direction = Vector2.RIGHT.rotated(player.aim_pivot.global_rotation)
			#var arrow : Arrow = ARROW.instantiate()
			#player.get_parent().add_child(arrow) # Add to world, not as child of player
			#var spawn_dist = 48.0
			#arrow.global_position = player.aim_pivot.global_position + (fire_direction * spawn_dist)
			#arrow.fire(fire_direction)
			#return null	
	#return null
	
#func HandleInput(_event: InputEvent) -> State:
	#print("*** HANDLEINPUT WYWOŁANY ***")  # TEST
	#print("Event: ", _event)
	#if _event.is_action_pressed("ability"):
		#print("*** ABILITY NACISNIĘTA ***")
		#if player.arrow_count <= 0:
			#return null
		#else:
			#player.arrow_count -= 1
			#
			## Oblicz dokładną pozycję docelową
			#var target_world_pos: Vector2
			#if player.is_using_controller:
				## POPRAWNA konwersja ekran→świat UŻYWAJĄC KAMERY
				#target_world_pos = get_viewport().get_camera_2d().get_global_transform().affine_inverse() * virtual_cursor_pos
			#else:
				#target_world_pos = player.get_global_mouse_position()
			#
			## Kierunek PROSTO z pozycji gracza do celownika
			#var fire_direction = (target_world_pos - player.global_position).normalized()
			#
			## DEBUG (usuń po naprawie)
			#print("=== STRZAŁ DEBUG ===")
			#print("Celownik ekran: ", virtual_cursor_pos)
			#print("Celownik świat: ", target_world_pos)
			#print("Gracz: ", player.global_position)
			#print("Kierunek: ", fire_direction)
			#print("==================")
			#
			#player.UpdateAnimation("bow")
			#player.animation_player.animation_finished.connect(_on_animation_finished)
			#
			#var arrow : Arrow = ARROW.instantiate()
			#player.get_parent().add_child(arrow)
			#var spawn_dist = 48.0
			#arrow.global_position = player.global_position + (fire_direction * spawn_dist)
			#arrow.fire(fire_direction)
			#
			#return null
	#return null
	
func HandleInput(_event: InputEvent) -> State:
	# Sprawdź trigger RT (Axis 5+) bezpośrednio
	var trigger_strength = Input.get_action_strength("ability")
	if trigger_strength > 0.7 and player.arrow_count > 0:
		print("ENTERING BOW STATE")
		return $"../Bow"

	return null

func _on_animation_finished(anim_name : String) -> void:
	if Input.is_action_pressed("aim"):
		next_state = $"../Aim"
	else:	
		next_state = idle
	pass
