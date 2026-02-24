# Enemies/Scripts/states/enemy_state_shoot.gd
class_name EnemyStateShoot extends EnemyState

const SPEAR = preload("res://Interactables/spear/spear.tscn")

@export var anim_name: String = "throw"
@export var shoot_cooldown: float = 1.5
@export var shoot_range: float = 150.0
@export var runaway_range: float = 80.0
@onready var line_of_sight_ray: RayCast2D = $"../../LineOfSightRay"

var _animation_finished: bool = true 
var _cooldown_timer: float = 0.0

func enter() -> void:
	print("entering shoot state")
	_cooldown_timer = 0.5
	_animation_finished = true 
	enemy.velocity = Vector2.ZERO
	line_of_sight_ray.add_exception(enemy)
	if not enemy.animation_player.animation_finished.is_connected(_on_animation_finished):
		enemy.animation_player.animation_finished.connect(_on_animation_finished)		

func exit() -> void:
	print("exiting shoot state")
	if enemy.animation_player.animation_finished.is_connected(_on_animation_finished):
		enemy.animation_player.animation_finished.disconnect(_on_animation_finished)

func process(_delta: float) -> EnemyState:
	_cooldown_timer -= _delta
	# While waiting/shooting, always face the player
	#if is_instance_valid(enemy.player):
		#print("player instance not valid")
	var dir = enemy.global_position.direction_to(enemy.player.global_position)
	enemy.set_direction(dir)
	# If the spear animation is currently playing, don't allow state changes
	if not _animation_finished:
		print("animation not finished")
		return null
	# Logic for switching states
	if PlayerManager.player.hp <= 0:
		print("player dead")
		return $"../Idle"
	var dist = enemy.global_position.distance_to(enemy.player.global_position)
	# 1. Check for transitions OUT of the shoot state
	if dist > shoot_range:
		print("player out of shoot range, going chase")
		return $"../Chase"
	elif dist < enemy.attack_range:
		print("player in attack range, going attack")
		return $"../Attack"
	elif dist < runaway_range:
		print("player too close, going flee")
		return $"../Flee"
	# 2. If we are still in range, check if we can shoot
	if _cooldown_timer <= 0:
		print("cooldown 0")
		if check_los():
			print("los ok going shoot")
			_shoot()
		else:
			print("los NOK going idle")
			#enemy.update_animation("idle")
			return $"../Chase" 	
	else:
		# While waiting for cooldown, play idle animation so they don't look broken
		print("cooldown in progress going idle")
		enemy.update_animation("idle") 
	return null

func _on_animation_finished(_a: String) -> void:
	_animation_finished = true
	print("animation finished")
	
func _shoot() -> void:
	if not is_instance_valid(enemy.player):
		return
	_cooldown_timer = shoot_cooldown
	_animation_finished = false	
	# Start the attack animation
	enemy.update_animation(anim_name)
	
func spawn_spear() -> void: # triggered by animation player
	# Spawn Spear
	var direction = enemy.global_position.direction_to(enemy.player.global_position)
	var spear : Spear = SPEAR.instantiate()
	if enemy.cardinal_direction == Vector2.DOWN:
		spear.global_position = enemy.global_position + (direction * 48)
	else:	
		spear.global_position = enemy.global_position + (direction * 38)
	spear.fire(direction)
	enemy.add_sibling(spear)
	pass	
	
#func check_los() -> bool:
	#line_of_sight_ray.target_position = enemy.to_local(enemy.player.global_position)
	#
	##if line_of_sight_ray.get_collision_exceptions().size() == 0:
		##line_of_sight_ray.add_exception(enemy)
	#
	#line_of_sight_ray.force_raycast_update()			
	#var collider = line_of_sight_ray.get_collider()
	#if line_of_sight_ray.is_colliding() and collider.is_in_group("player"):
		#print("los ok")
		#return true
	#print("los nok")	
	#return false	

func check_los() -> bool:
	if not is_instance_valid(enemy.player):
		return false
	
	# 1. Calculate the vector from the RAY'S global position to the PLAYER'S global position
	# Subtracting the ray's global position from the player's global position gives us 
	# the exact vector needed to reach the player.
	var global_direction = enemy.player.global_position - line_of_sight_ray.global_position
	
	# 2. We must convert this global vector into the RayCast's local coordinate space.
	# We use '.rotated(-line_of_sight_ray.global_rotation)' to cancel out any 
	# rotation the RayCast or its parents might have.
	line_of_sight_ray.target_position = global_direction.rotated(-line_of_sight_ray.global_rotation)
	
	line_of_sight_ray.force_raycast_update()			
	
	if line_of_sight_ray.is_colliding():
		var collider = line_of_sight_ray.get_collider()
		if collider:
			# Check if we hit the player (or their hitbox)
			if collider.is_in_group("player") or (collider.owner and collider.owner.is_in_group("player")):
				return true
				
	return false
