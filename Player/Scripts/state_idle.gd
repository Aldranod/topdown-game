class_name State_Idle extends State

@onready var walk: State = $"../Walk"	
@onready var attack: State = $"../Attack"
@onready var dash: State = $"../Dash"
@onready var second_attack: State = $"../SecondAttack"
@onready var third_attack: State_ThirdAttack = $"../ThirdAttack"
@onready var run: State = $"../Run"
@onready var heal: State_Heal = $"../Heal"
@onready var falling: State_Falling = $"../Falling"
@onready var fall_box: Area2D = $"../../FallBox"

func Enter() -> void:
	#fall_box.monitoring = true
	$"../../Label2".text = "idle"
	player.UpdateAnimation("idle")
	pass
	
func Exit() -> void:
	#fall_box.monitoring = false
	pass
	
func Process(_delta: float) -> State:
	#if _is_over_abyss():
		#print("falling")
		#state_machine.change_state(falling)
	if player.direction != Vector2.ZERO:
		# Check if stick is pushed hard enough to run
		if player.stick_intensity >= 0.7:  # Same threshold as run state
			return run  # Go to run instead of walk
		return walk
	player.velocity = Vector2.ZERO
	return null

func Physics(_delta: float) -> State:
	return null	

func HandleInput( _event: InputEvent) -> State:
	if _event.is_action_pressed("attack") and PlayerManager.INVENTORY_DATA.check_if_equiped("Iron Sword"):
		print("attack")
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
		if PlayerManager.player.can_dash():
			return dash
		else:
			return null
	return null						

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
