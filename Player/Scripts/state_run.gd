class_name State_Run extends State

@export var run_speed:  float = 180.0  # Faster than walk
@export var stick_threshold: float = 0.7  # How hard to push stick (0.7 = 70%)
@export var ACCELERATION = 1500.0  # 
@export var FRICTION = 1200.0      # 

@onready var idle: State = $"../Idle"
@onready var walk: State = $"../Walk"
@onready var attack: State = $"../Attack"
@onready var second_attack: State = $"../SecondAttack"
@onready var third_attack: State_ThirdAttack = $"../ThirdAttack"
@onready var dash: State = $"../Dash"
@onready var heal: State_Heal = $"../Heal"

func Enter() -> void:
	$"../../Label2".text = "run"
	player.UpdateAnimation("run")
	pass

func Exit() -> void:
	pass

func Process(_delta: float) -> State:
	# If stick released or not pushed hard enough, go back to walk
	#if player.direction == Vector2.ZERO: 
		#return idle
	if player.stick_intensity < stick_threshold: 
		return walk  # Stick not pushed hard enough, walk instead
	#if Input.is_action_pressed("walk"):
		#return walk
	#player.velocity = player.direction * run_speed
	var input_vector = Input.get_vector("left", "right", "up", "down")
	if input_vector != Vector2.ZERO:
		if player.stick_intensity > 0.9:
			run_speed = 180	
		player.velocity = player.velocity.move_toward(input_vector * run_speed, ACCELERATION * _delta)
	else:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, FRICTION * _delta)
		if player.direction == Vector2.ZERO: 
			return idle
	if player.SetDirection():
		player.UpdateAnimation("run")
	return null

func Physics(_delta: float) -> State:
	return null

func HandleInput(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack") and PlayerManager.INVENTORY_DATA.check_if_equiped("Iron Sword"):
		if PlayerManager.player.third_attack_window_open:
			return third_attack
		if PlayerManager.player.combo_window_open:
			return second_attack
		if PlayerManager.player.attack_window_open:
			return attack
	elif _event.is_action_pressed("aim"):
		return $"../Aim"			
	elif _event.is_action_pressed("interact"):
		PlayerManager.interact()
	elif _event.is_action_pressed("heal"):
		if player.wrath >= $"../Heal".heal_wrath_cost:
			return heal
		else:
			PlayerHud.low_wrath()
	elif _event.is_action_pressed("dash"):
		if player.can_dash():
			player.start_dash_cooldown()
			return dash
	return null
