class_name State_Aim extends State

@onready var idle: State = $"../Idle"
@onready var aim_sprite: Sprite2D = $"../../AimPivot/AimSprite"
@export var rotation_speed: float = 10.0
@export var fire_cooldown: float = 0.5
@export var shoot_wrath_cost: int = 2
# ADS Snapping settings
@export_group("ADS Snapping")
@export var ads_snap_enabled: bool = true
@export var ads_snap_radius: float = 200.0      # world units — how far to detect enemies
@export var ads_snap_angle_deg: float = 45.0    # cone width — only snap if enemy within this angle
@export var ads_snap_speed: float = 15.0        # how fast the snap lerps to target
@export var ads_max_snap_distance: float = 20.0 # how close aim must be to enemy (screen units) to trigger

const ARROW = preload("res://Interactables/arrow/wrath_arrow.tscn")

var cooldown_timer: float = 0.0
var already_firing: bool = false
var snap_target: Node2D = null  # the enemy we're snapping toward

func Enter() -> void:
	$"../../Label2".text = "aim"
	$"../../AimPivotMouse/AimPivotMouseSprite".visible = false
	player.aim_sprite_visible = true
	aim_sprite.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	player.velocity = Vector2.ZERO
	player.UpdateAnimation("idle")
	cooldown_timer = 0.0
	already_firing = false
	if ads_snap_enabled:
		snap_target = _find_snap_target()
	if snap_target == null:
		aim_sprite.rotation = player.cardinal_direction.angle()	

func Exit() -> void:
	$"../../AimPivotMouse/AimPivotMouseSprite".visible = true
	player.aim_sprite_visible = false
	aim_sprite.visible = false
	already_firing = false
	snap_target = null

func Process(delta: float) -> State:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	var trigger_strength = Input.get_action_strength("ability_trigger")
	if trigger_strength < 0.2:
		already_firing = false
	var v = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
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
	if not already_firing:
		player.UpdateAnimation("idle")
	if Input.is_action_just_released("aim"):
		return idle
	return null

func HandleInput(_event: InputEvent) -> State:
	var trigger_strength = Input.get_action_strength("ability_trigger")
	if trigger_strength < 0.2 or cooldown_timer > 0.0 or already_firing:
		return null
	if player.wrath < 2:
		PlayerHud.low_wrath()
		return null	
		
	already_firing = true
	cooldown_timer = fire_cooldown
	player.consume_wrath(shoot_wrath_cost)

	player.face_target(aim_sprite.global_position)
	set_direction()
	player.UpdateAnimation("bow")

	if not player.animation_player.animation_finished.is_connected(_on_animation_finished):
		player.animation_player.animation_finished.connect(_on_animation_finished)

	var fire_direction = Vector2.RIGHT.rotated(aim_sprite.global_rotation)
	var arrow: Arrow = ARROW.instantiate()
	player.get_parent().add_child(arrow)
	arrow.global_position = aim_sprite.global_position + (fire_direction * 58.0)
	arrow.fire(fire_direction)
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

func _on_animation_finished(anim_name: String) -> void:
	player.animation_player.animation_finished.disconnect(_on_animation_finished)

func set_direction() -> void:
	var aim_direction = Vector2.RIGHT.rotated(aim_sprite.rotation)
	var direction_id = posmod(int(round(aim_direction.angle() / TAU * player.DIR_4.size())), player.DIR_4.size())
	var new_cardinal = player.DIR_4[direction_id]
	if new_cardinal != player.cardinal_direction:
		player.cardinal_direction = new_cardinal
		player.DirectionChanged.emit(new_cardinal)
		player.sprite.scale.x = -1 if new_cardinal == Vector2.LEFT else 1
