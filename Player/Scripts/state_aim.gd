class_name State_Aim extends State

@onready var idle: State = $"../Idle"
@onready var aim_sprite: Sprite2D = $"../../AimPivot/AimSprite"
@export var rotation_speed: float = 10.0
@export var fire_cooldown: float = 0.5
@export var shoot_wrath_cost: int = 2
@export var side_half_angle_deg : float = 22.5      # połowa sektora "bok" (22.5 = 45° łącznie)
@export var direction_hysteresis_deg : float = 3.0  # zapobiega migotaniu na granicy sektorów
# ADS Snapping settings
@export_group("ADS Snapping")
@export var ads_snap_enabled: bool = true
@export var ads_snap_radius: float = 200.0      # world units — how far to detect enemies
@export var ads_snap_angle_deg: float = 45.0    # cone width — only snap if enemy within this angle
@export var ads_snap_speed: float = 15.0        # how fast the snap lerps to target
@export var ads_max_snap_distance: float = 20.0 # how close aim must be to enemy (screen units) to trigger
@export var move_speed : float = 50.0

const ARROW = preload("res://Interactables/arrow/wrath_arrow.tscn")

var cooldown_timer: float = 0.0
var already_firing: bool = false
var snap_target: Node2D = null  # the enemy we're snapping toward
var pending_dir : Vector2 = Vector2.ZERO
var has_pending_arrow : bool = false

@export var draw_hold_time : float = 0.4   # czas 9. klatki w bow_* (klatka N ma czas (N-1)*0.05)
var _drawing : bool = false     # napinanie (klatki 1-9)
var _holding : bool = false     # łuk napięty, animacja wstrzymana
var _releasing : bool = false   # wypuszczanie (klatki 10+)

func Enter() -> void:
	has_pending_arrow = false
	$"../../Label2".text = "aim"
	$"../../AimPivotMouse/AimPivotMouseSprite".visible = false
	player.aim_sprite_visible = true
	aim_sprite.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	player.velocity = Vector2.ZERO
	_start_draw()
	if not player.animation_player.animation_finished.is_connected(_on_animation_finished):
		player.animation_player.animation_finished.connect(_on_animation_finished)
	cooldown_timer = 0.0
	already_firing = false
	if ads_snap_enabled:
		snap_target = _find_snap_target()
	if snap_target == null:
		aim_sprite.rotation = player.cardinal_direction.angle()	

func Exit() -> void:
	has_pending_arrow = false
	$"../../AimPivotMouse/AimPivotMouseSprite".visible = true
	player.aim_sprite_visible = false
	aim_sprite.visible = false
	already_firing = false
	snap_target = null
	_drawing = false
	_holding = false
	_releasing = false
	if player.animation_player.animation_finished.is_connected(_on_animation_finished):
		player.animation_player.animation_finished.disconnect(_on_animation_finished)
	player.animation_player.stop()   # zdejmuje pauzę, żeby kolejny stan zaczął animację od początku
	player.sprite.scale.x = -1 if player.cardinal_direction == Vector2.LEFT else 1
	
func Process(delta: float) -> State:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	var trigger_strength = Input.get_action_strength("ability_trigger")
	if trigger_strength < 0.2:
		already_firing = false
	var move_mode : bool = player.can_move_while_shooting()
	var v = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X if move_mode else JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y if move_mode else JOY_AXIS_LEFT_Y)
	)
	if v.length() > 0.6:
		snap_target = null
		var target_angle = v.angle()
		aim_sprite.rotation = lerp_angle(aim_sprite.rotation, target_angle, rotation_speed * delta)
	elif snap_target != null and is_instance_valid(snap_target):
		var dir_to_target = (snap_target.global_position - player.global_position).normalized()
		var target_angle = dir_to_target.angle()
		aim_sprite.rotation = lerp_angle(aim_sprite.rotation, target_angle, ads_snap_speed * delta)
	set_direction()
	if move_mode:
		player.velocity = Input.get_vector("left", "right", "up", "down") * move_speed
	else:
		player.velocity = Vector2.ZERO

	# Napinanie -> zatrzymanie na klatce 9
	var ap : AnimationPlayer = player.animation_player
	if _drawing and ap.current_animation_position >= draw_hold_time:
		_drawing = false
		_holding = true
		ap.seek(draw_hold_time, true)
		ap.pause()
	if _drawing or _holding:
		_sync_bow_direction()   # zmiana kierunku celowania zmienia bow_down/side/up
	# Strzał: trigger wciśnięty, łuk napięty
	if _holding and trigger_strength >= 0.2 and not already_firing and cooldown_timer <= 0.0:
		_try_fire()

	if Input.is_action_just_released("aim"):
		return idle
	return null

func _find_snap_target() -> Node2D:
	var snap_angle_rad = deg_to_rad(ads_snap_angle_deg)
	var best_target: Node2D = null
	var best_score: float = INF  # lower = better (angle distance to aim line)
	var camera = player.get_viewport().get_camera_2d()
	var viewport_size = player.get_viewport().get_visible_rect().size
	var camera_top_left = camera.global_position - viewport_size / 2 / camera.zoom
	var camera_bottom_right = camera.global_position + viewport_size / 2 / camera.zoom
	var camera_rect = Rect2(camera_top_left, camera_bottom_right - camera_top_left)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		 # Skip if node is not visible or not in scene
		if not enemy is Node2D:
			continue
		if not enemy.is_visible_in_tree():
			continue
		if not is_instance_valid(enemy):
			continue
		if not camera_rect.has_point(enemy.global_position):
			continue	
		var to_enemy = enemy.global_position - player.global_position
		var distance = to_enemy.length()
		if distance > ads_snap_radius:
			continue
		var angle_to_enemy = to_enemy.angle()
		var angle_diff = abs(angle_difference(aim_sprite.rotation, angle_to_enemy))
		if angle_diff > snap_angle_rad:
			continue
		if angle_diff < best_score:
			best_score = angle_diff
			best_target = enemy
	return best_target

func _on_animation_finished(anim_name: StringName) -> void:
	if not String(anim_name).begins_with("bow"):
		return
	if _releasing:
		_releasing = false
		_start_draw()   # po strzale napnij łuk od nowa
		
func set_direction() -> void:
	var aim_direction : Vector2 = Vector2.RIGHT.rotated(aim_sprite.rotation)
	# kąt między wektorem celowania a osią poziomą (0° = idealnie w bok, 90° = góra/dół)
	var off_axis : float = rad_to_deg(asin(clampf(absf(aim_direction.y), 0.0, 1.0)))
	var in_side : bool = player.cardinal_direction == Vector2.LEFT or player.cardinal_direction == Vector2.RIGHT
	# histereza: łatwiej zostać w bok niż do niego wejść
	var limit : float = side_half_angle_deg + (direction_hysteresis_deg if in_side else -direction_hysteresis_deg)
	var new_cardinal : Vector2
	if off_axis <= limit:
		new_cardinal = Vector2.RIGHT if aim_direction.x >= 0.0 else Vector2.LEFT
	else:
		new_cardinal = Vector2.DOWN if aim_direction.y > 0.0 else Vector2.UP
	if new_cardinal != player.cardinal_direction:
		player.cardinal_direction = new_cardinal
		player.DirectionChanged.emit(new_cardinal)
	var flip : bool
	if new_cardinal == Vector2.LEFT:
		flip = true
	elif new_cardinal == Vector2.DOWN or new_cardinal == Vector2.UP:
		if aim_direction.x < -0.1:
			flip = true
		elif aim_direction.x > 0.1:
			flip = false
		else:
			flip = player.sprite.scale.x < 0   # tuż przy pionie: zostaw obecny stan (bez migotania)
	else:
		flip = false
	player.sprite.scale.x = -1 if flip else 1	
				
func release_arrow() -> void:
	if not has_pending_arrow:
		return
	has_pending_arrow = false
	if not player.fire_arrow(ARROW, aim_sprite.global_position, pending_dir):
		player.add_wrath(shoot_wrath_cost)   # zwrot kosztu, strzał zablokowany przez ścianę		

func _try_fire() -> void:
	already_firing = true   # do puszczenia triggera
	if player.wrath < shoot_wrath_cost:
		PlayerHud.low_wrath()
		return
	cooldown_timer = fire_cooldown
	player.consume_wrath(shoot_wrath_cost)
	set_direction()
	_sync_bow_direction()
	pending_dir = Vector2.RIGHT.rotated(aim_sprite.global_rotation)
	has_pending_arrow = true
	_holding = false
	_releasing = true
	player.animation_player.play()   # wznawia od klatki 9; strzała wylatuje na 0,45 s (spawn_arrow)

func _start_draw() -> void:
	_drawing = true
	_holding = false
	_releasing = false
	player.animation_player.play("bow_" + player.AnimDirection())

# Przy zmianie kierunku celowania przełącza bow_* z zachowaniem pozycji w animacji.
func _sync_bow_direction() -> void:
	var ap : AnimationPlayer = player.animation_player
	var wanted : String = "bow_" + player.AnimDirection()
	if ap.assigned_animation == wanted:
		return
	var pos : float = ap.current_animation_position
	ap.play(wanted)
	ap.seek(pos, true)
	if _holding:
		ap.pause()	
