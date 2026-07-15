class_name Player extends CharacterBody2D

signal DirectionChanged( new_direction: Vector2)
signal player_damaged( hurt_box : HurtBox)
signal player_dashing
@export var dash_cooldown_duration: float = 1.5
@export var player_inv: bool = false
const DIR_4 = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
var _material: ShaderMaterial
var _target_vignette: float = 0.2
var _current_vignette: float = 0.2
var stick_intensity:  float = 0.0  # 0.0 to 1.0
var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

var invulnerable : bool = false
var hp : int = 6
var max_hp : int = 6

var wrath : int = 0
var max_wrath : int = 10
var wrath_per_hit : int = 1

var level : int = 1
var xp: int = 0

var attack : int =1 :
	set( v ):
		attack = v
		update_damage_values()
var defense : int = 1
var defense_bonus: int = 0

var dash_cooldown_timer: float = 0.0 

var arrow_count : int = 0 : set = _set_arrow_count
var bomb_count : int = 0 : set = _set_bomb_count

var combo_window_open : bool = false
var attack_window_open : bool = true
var third_attack_window_open : bool = false

var distance_in_pixel : float
var initial_position

var is_using_controller : bool = false
var last_controller_direction : Vector2 = Vector2.DOWN
var aim_sprite_visible: bool = false
var dash_start_position: Vector2 = Vector2.ZERO

@onready var camera_2d: PlayerCamera = $Camera2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var hit_box: HitBox = $HitBox
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine : PlayerStateMachine = $StateMachine
@onready var audio: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var lift: State_Lift = $StateMachine/Lift
@onready var held_item: Node2D = $Sprite2D/HeldItem
@onready var carry: State_Carry = $StateMachine/Carry
@onready var player_abilities: PlayerAbilities = $Abilities
@onready var combo_timer: Timer = $ComboTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var third_attack_timer: Timer = $ThirdAttackTimer
@onready var fall_box: Area2D = $FallBox
@onready var falling: State_Falling = $StateMachine/Falling					

func _ready():
	PlayerManager.player = self
	initial_position = global_position
	state_machine.Initialize(self)
	hit_box.Damaged.connect( _take_damage)
	update_hp(99)
	update_damage_values()
	PlayerManager.player_leveled_up.connect(_on_player_leveled_up)
	PlayerManager.INVENTORY_DATA.equipment_changed.connect(_on_equipment_changed)
	update_wrath_ui()
	_material = $Camera2D/ColorRect.get_material() as ShaderMaterial
	if not _material:
		push_error("Player: No ShaderMaterial found!")
		return
	_material.set_shader_parameter("vignette_opacity", _current_vignette)
	pass
	
func _process(_delta):
	if player_inv:
		invulnerable = true
	if fall_box.monitoring == true and _is_over_abyss():
		state_machine.change_state(falling)
	var in_aim_state = state_machine.current_state is State_Aim
	if not in_aim_state:
		direction = Vector2(
			Input.get_axis("left", "right"),
			Input.get_axis("up", "down")
		).normalized()
		
		if direction.length() > 0.1:
			last_controller_direction = direction
		# Calculate stick intensity (how far the stick is pushed)
		var raw_input = Vector2(
			Input.get_axis("left", "right"),
			Input.get_axis("up", "down")
		)
		stick_intensity = raw_input.length()  # Returns 0.0 to ~1.414
		stick_intensity = clamp(stick_intensity, 0.0, 1.0)  # Clamp to 0-1
	
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= _delta
	if _current_vignette != _target_vignette:
		_current_vignette = lerp(_current_vignette, _target_vignette, _delta * 3.0)
		if _material:
			_material.set_shader_parameter("vignette_opacity", _current_vignette)	
	PlayerHud.update_dash_cooldown(dash_cooldown_timer, dash_cooldown_duration)
	dust_emit()
	pass	
	
func _physics_process(_delta):
	initial_position = global_position
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventMouseButton or event is InputEventKey:
		if is_using_controller:
			is_using_controller = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			$AimPivotMouse/AimPivotMouseSprite.visible = true
	# Detect Controller
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if not is_using_controller:
			is_using_controller = true
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			$AimPivotMouse/AimPivotMouseSprite.visible = false
	if event.is_action_pressed("test"):
		#update_hp(-99)
		#player_damaged.emit(%AttackHurtBox)
		PlayerManager.shake_camera()
	pass	
	
func SetDirection() -> bool:
	if direction == Vector2.ZERO:
		return false
	var direction_id : int = int( round( ( direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size() ) )
	var new_dir = DIR_4[ direction_id]
	if new_dir ==  cardinal_direction:
		return false
	cardinal_direction = new_dir
	DirectionChanged.emit(new_dir)
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true				

func UpdateAnimation( state : String ) -> void:
	animation_player.play( state + "_" + AnimDirection())
	pass

func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
		
func _take_damage( hurt_box : HurtBox) -> void:
	if invulnerable == true:
		return
	if hp > 0:
		var dmg : int = hurt_box.damage
		if dmg > 0:
			dmg = clampi(dmg - defense - defense_bonus,1,dmg)
		print(dmg)
		update_hp( -dmg)
		player_damaged.emit(hurt_box)
	pass
	
func update_hp( delta : int) -> void:
	hp = clampi( hp + delta, 0, max_hp)
	PlayerHud.update_hp( hp, max_hp)
	if hp <= max_hp * 0.3:  # Low health
		_target_vignette = 0.5
	else:  # Full health
		_target_vignette = 0.1
	pass
	
func make_invulnerable( _duration : float = 1.0 ) -> void:
	invulnerable = true
	hit_box.monitoring = false
	await get_tree().create_timer(_duration).timeout
	invulnerable = false
	hit_box.monitoring = true
	pass

func pickup_item(_t : Throwable) -> void:
	state_machine.change_state(lift)
	carry.throwable = _t
	#store throwable object
	pass			 							

func revive_player() -> void:
	update_hp(99)
	state_machine.change_state($StateMachine/Idle)
	
func update_damage_values() -> void:
	var damage_value : int= attack + PlayerManager.INVENTORY_DATA.get_attack_bonus()
	%AttackHurtBox.damage = damage_value
	%ChargeSpinHurtBox.damage = damage_value * 2
	
func _on_player_leveled_up() -> void:
	effect_animation_player.play("level_up")
	update_hp(max_hp)
	pass	

func _on_equipment_changed() -> void:
	update_damage_values()
	defense_bonus = PlayerManager.INVENTORY_DATA.get_defense_bonus()

func _set_arrow_count( value : int) -> void:
	arrow_count = value
	PlayerHud.update_arrow_count(value)
	pass
	
func _set_bomb_count( value : int) -> void:
	bomb_count = value
	PlayerHud.update_bomb_count(value)
	pass
	
func can_dash() -> bool:
	if SaveManager.current_save.dash == false:
		return false
	player_dashing.emit()
	return dash_cooldown_timer <= 0.0

func start_dash_cooldown() -> void:
	dash_cooldown_timer = dash_cooldown_duration
	pass

func _on_attack_timer_timeout() ->void:
	attack_window_open = true
	pass

func start_attack() ->void:
	if not attack_timer.is_stopped():
		attack_window_open = false
		return
	attack_timer.start()
	attack_window_open = false
	pass	

func _on_combo_timer_timeout() ->void:
	combo_window_open = false
	pass

func start_combo() ->void:
	if not combo_timer.is_stopped():
		combo_window_open = true
		return
	combo_timer.start()
	combo_window_open = true
	pass					

func _on_third_attack_timer_timeout() -> void:
	third_attack_window_open = false

# Call this from the Second Attack animation
func start_third_attack_window() -> void:
	if not third_attack_timer.is_stopped():
		third_attack_window_open = true
		return
	third_attack_timer.start()
	third_attack_window_open = true

func player_camera_switch() -> void:
	camera_2d.make_current()

func player_light_switch(value: bool) -> void:	
	$PointLight2D.visible = value

func dust_emit() -> void:
	distance_in_pixel += global_position.distance_to(initial_position)
	if distance_in_pixel >= 68:
		distance_in_pixel -= 68
		EffectManager.emit_dust(PlayerManager.player)	
	pass	

func face_target(target_pos: Vector2) -> void:
	var direction_to_target = (target_pos - global_position).normalized()
	if direction_to_target != Vector2.ZERO:
		var direction_id : int = int( round( direction_to_target.angle() / TAU * DIR_4.size() ) )
		cardinal_direction = DIR_4[ direction_id]
		DirectionChanged.emit(cardinal_direction)
		sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1

func add_wrath(amount: int) -> void:
	#Add wrath when hitting enemy
	wrath = min(max_wrath, wrath + amount)
	update_wrath_ui()
	
func consume_wrath(amount: int) -> bool:
	if wrath >= amount:
		wrath -= amount
		update_wrath_ui()
		return true
	return false
	
func update_wrath_ui() -> void:
	PlayerHud.update_wrath(wrath, max_wrath)
	pass

func _is_over_abyss() -> bool:
	"""Check if hitbox is overlapping with an Abyss area"""
	if not fall_box:
		return false
	var overlapping_areas = fall_box.get_overlapping_bodies()
	for area in overlapping_areas:
		print(area)	
		# Option 1: Check by group
		if area.is_in_group("abyss"):
			return true
	return false
