class_name BossStateIdle extends EnemyState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min : float = 0.5
@export var state_duration_max : float = 1.5
@export var after_idle_state : EnemyState
@export var chase_state: BossStateChase # Add an export for the chase state

var _timer : float = 0.0
var flee_timer : float = 0.0

# We need references to the vision components.
# This assumes the Chase state holds the reference to the VisionArea.
@onready var vision_area: VisionArea = $"../../VisionArea"
@onready var line_of_sight_ray: RayCast2D = $"../../LineOfSightRay"
@onready var idle: BossStateIdle= $"."
@onready var attack_state: BossStateAttack = $"../Attack"
@onready var enemy_state_machine: EnemyStateMachine = $".."
@onready var circling: BossStateCircle = $"../Circling"
@onready var telegraph_state: BossStateTelegraph = $"../Telegraph"
@onready var boss: Boss1 = $"../.."

@export_category("Distance Thresholds")
@export var circle_distance : float = 80.0
@export var telegraph_distance : float = 150.0
@export var close_chase_distance : float = 60.0
@onready var flee_state: BossStateFlee = $"../Flee"

func init() -> void:
	pass
	
func enter() -> void:
	$"../../Label".text = "idle"
	$"../../Sprite2D/AttackHurtBox".monitoring = false
	enemy.velocity = Vector2.ZERO
	if boss.stage2:
		_timer = 0.1
	else:	
		_timer = randf_range(state_duration_min, state_duration_max)
	enemy.update_animation( anim_name)
	pass
	
func exit() -> void:
	pass
	
#func process( _delta: float ) -> EnemyState:
	#if PlayerManager.player.hp > 0:
		#if enemy._in_attack_range(): 
			#return attack_state
		##if randf() <= 0.20:  # 20% chance to random state	
			##return random_state()
		#if player_in_charge_range() and enemy.global_position.distance_to(PlayerManager.player.position) >= 150: 
			#return $"../Telegraph"
		#if enemy.global_position.distance_to(PlayerManager.player.position) <= 60:
			#return chase_state
		#else:
			##return $"../Flee"
			##return null
			#return random_state()
		#_timer -= _delta
		#if _timer <= 0:
			#return after_idle_state
		#else:	
			#return idle
	#else:			
		#return null

func process(_delta: float) -> EnemyState:
	var distance_to_player = enemy.global_position.distance_to(PlayerManager.player.global_position)
	if PlayerManager.player.hp <= 0:
		return null
	# PRIORITY 1: Check for consecutive hits (flee condition)
	if boss.consecutive_hits >= boss.consecutive_hit_threshold:
		return flee_state if flee_state else $"../Flee"
	# PRIORITY 2: Attack if in range
	if enemy._in_attack_range():
		return attack_state
	# PRIORITY 3: Check vision and determine appropriate state
	if vision_area and player_in_vision():
		if randf() <= 0.5: # if stage 2 or player healing call help, else 25% chance to call help
			if boss.stage2 or \
			   PlayerManager.player.state_machine.current_state == State_Heal and enemy.hp < 60 or \
			   randf() <= 0.25 and enemy.hp < 60:
				return call_help_check()		
		elif distance_to_player <= close_chase_distance:
			return chase_state
		#elif distance_to_player >= telegraph_distance :
			#return telegraph_state	
		else:
			#return chase_state	
			return telegraph_state
		#if PlayerManager.player.state_machine.current_state == State_Heal and enemy.hp < 60:
			#return call_help_check()
		#if boss.stage2:
			#if randf() <= 0.45: #45 percent chance if stage 2
				#return call_help_check()
		#else:		
			#if randf() <= 0.25 and enemy.hp < 60: #25 percent chance
				#return call_help_check()
				
		# Very close - chase aggressively
		#if distance_to_player <= close_chase_distance:
			#return chase_state
		#elif distance_to_player >= telegraph_distance :
			#return telegraph_state
		## Default - chase
		#else:
			#return chase_state

	# PRIORITY 5: Wait for idle timer
	_timer -= _delta
	if _timer <= 0:
		return after_idle_state
	
	return null


func physics( _delta: float ) -> EnemyState:
	return null			

func player_in_charge_range() -> bool:
	if vision_area.get_overlapping_bodies().has(enemy.player):
		# If they are, do the expensive raycast check.
		line_of_sight_ray.target_position = enemy.to_local(enemy.player.global_position)
		line_of_sight_ray.force_raycast_update()
		# If the first thing we see is the player, start chasing or shooting!
		var collider = line_of_sight_ray.get_collider()
		if is_instance_valid(collider) and collider.is_in_group("player"):
			return true
		else:
			return false	
	else:
		return false				
	
func call_help_check()	-> EnemyState:
	var minions_number = get_tree().get_nodes_in_group("bossminion").size()
	if boss.stage2 and minions_number < 3:
		return $"../CallHelp"
	elif not boss.stage2 and minions_number <2:
		return $"../CallHelp"	
	else:
		return chase_state	

func player_in_vision() -> bool:
	if vision_area:
		return vision_area.get_overlapping_bodies().has(enemy.player)
	return false
