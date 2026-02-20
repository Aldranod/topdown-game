# Enemies/Scripts/states/enemy_state_shoot.gd
#class_name EnemyStateShoot extends EnemyState
#
#const ARROW = preload("res://Interactables/arrow/arrow.tscn")
#
#@export var anim_name: String = "attack"
#@export var shoot_cooldown: float = 1.5
#@export var arrow_fire_audio: AudioStream = preload("res://Player/Audio/bow_fire.wav")
#@export var shoot_range: float = 150.0
#@export var runaway_range: float = 80
#
#@export_category("AI")
#
#var _animation_finished: bool = false
#var _cooldown_timer: float = 0.0
#
#func init() -> void:
	#pass
#
#func enter() -> void:
	#_cooldown_timer = shoot_cooldown
	#_animation_finished = true
	#enemy.velocity = Vector2.ZERO
	#if not enemy.animation_player.animation_finished.is_connected(_on_animation_finished):
		#enemy.animation_player.animation_finished.connect(_on_animation_finished)
	##_shoot()
	#pass
#
#func exit() -> void:
	#if enemy.animation_player.animation_finished.is_connected(_on_animation_finished):
		#enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	#pass
#
#func process(_delta: float) -> EnemyState:
	#if _cooldown_timer > 0:
		#_cooldown_timer -= _delta
	#if _animation_finished:
		#if PlayerManager.player.hp > 0:
			#var distance_to_player = enemy.global_position.distance_to(enemy.player.global_position)
			#if distance_to_player > shoot_range:
				#return $"../Idle"
			#elif distance_to_player <= shoot_range and distance_to_player >= runaway_range:
				#if _cooldown_timer <= 0:
					#_shoot()
				#else:
					#return null	
			#elif distance_to_player < runaway_range and distance_to_player > enemy.attack_range:
				#return $"../Flee"
			#elif distance_to_player <= enemy.attack_range:
				#return $"../Attack"		
			#else:
				#return $"../Idle"
			#return null	
		#else: # player dead, go to idle
			#return	$"../Idle"
	#else: # animation not finished, do nothing
		#return	null
#
#func physics(_delta: float) -> EnemyState:
	#return null
#
#func _on_animation_finished(_a: String) -> void:
	#_animation_finished = true
#
#func _shoot() -> void:
	#if not is_instance_valid(enemy.player):
		#return
	##enemy.animation_player.animation_finished.connect(_on_animation_finished)	
	#_cooldown_timer = shoot_cooldown
	#_animation_finished = false # We started a new shot, so animation isn't finished yet	
	##Face the player
	#var direction_to_player = enemy.global_position.direction_to(enemy.player.global_position)
	#enemy.set_direction(direction_to_player)
	#enemy.update_animation(anim_name)
	### Create arrow
	##var arrow: Arrow = ARROW.instantiate()
	##arrow.global_position = enemy.global_position + Vector2(20,20)
	##enemy.add_sibling(arrow)
	### Calculate direction to player
	##var fire_direction = enemy.global_position.direction_to(enemy.player.global_position)
	##arrow.fire(fire_direction)	
	#var	direction = enemy.global_position.direction_to(enemy.player.global_position)
	#var arrow : Arrow = ARROW.instantiate()
	#arrow.global_position = enemy.global_position + (direction * 44)
	#enemy.add_sibling(arrow)
	#arrow.fire(direction)	

# Enemies/Scripts/states/enemy_state_shoot.gd
class_name EnemyStateShoot extends EnemyState

const ARROW = preload("res://Interactables/arrow/arrow.tscn")

@export var anim_name: String = "attack"
@export var shoot_cooldown: float = 1.5
@export var shoot_range: float = 150.0
@export var runaway_range: float = 80.0

var _animation_finished: bool = true 
var _cooldown_timer: float = 0.0

func enter() -> void:
	# Start the timer when we enter
	_cooldown_timer = 0.5
	_animation_finished = true 
	enemy.velocity = Vector2.ZERO
	
	if not enemy.animation_player.animation_finished.is_connected(_on_animation_finished):
		enemy.animation_player.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	if enemy.animation_player.animation_finished.is_connected(_on_animation_finished):
		enemy.animation_player.animation_finished.disconnect(_on_animation_finished)

func process(_delta: float) -> EnemyState:
	_cooldown_timer -= _delta
	
	# While waiting/shooting, always face the player
	if is_instance_valid(enemy.player):
		var dir = enemy.global_position.direction_to(enemy.player.global_position)
		enemy.set_direction(dir)

	# If the arrow animation is currently playing, don't allow state changes
	if not _animation_finished:
		return null

	# Logic for switching states
	if PlayerManager.player.hp <= 0:
		return $"../Idle"

	var dist = enemy.global_position.distance_to(enemy.player.global_position)
	
	# 1. Check for transitions OUT of the shoot state
	if dist > shoot_range:
		return $"../Idle"
	elif dist < enemy.attack_range:
		return $"../Attack"
	elif dist < runaway_range:
		return $"../Flee"

	# 2. If we are still in range, check if we can shoot
	if _cooldown_timer <= 0:
		_shoot()
	else:
		# While waiting for cooldown, play idle animation so they don't look broken
		enemy.update_animation("idle") 
		
	return null

func _on_animation_finished(_a: String) -> void:
	_animation_finished = true

func _shoot() -> void:
	if not is_instance_valid(enemy.player):
		return
	
	_cooldown_timer = shoot_cooldown
	_animation_finished = false	
	# Start the attack animation
	enemy.update_animation(anim_name)
	# Spawn Arrow
	var direction = enemy.global_position.direction_to(enemy.player.global_position)
	var arrow : Arrow = ARROW.instantiate()
	arrow.global_position = enemy.global_position + (direction * 44)
	enemy.add_sibling(arrow)
	arrow.fire(direction)
