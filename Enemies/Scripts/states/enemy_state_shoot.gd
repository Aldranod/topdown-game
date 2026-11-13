# Enemies/Scripts/states/enemy_state_shoot.gd
class_name EnemyStateShoot extends EnemyState

const SPEAR = preload("res://Interactables/spear/spear.tscn")
const OBSTACLE_MASK := 16   # warstwa 5: drzewa, budynki, ściany (taka jak w masce strzały)
const PATHFINDER : PackedScene = preload("res://Enemies/pathfinder.tscn")

const MUZZLE := {
	"down": Vector2(20, 20),
	"up":   Vector2(20, -20),
	"side": Vector2(22, 0),   # x zostanie odbite zależnie od strony
}

@export var anim_name: String = "throw"
@export var shoot_cooldown: float = 1.5
@export var shoot_range: float = 150.0
@export var runaway_range: float = 80.0
@export var reposition_speed : float = 70.0
@export var min_spot_distance : float = 110.0

var _animation_finished: bool = true 
var _cooldown_timer: float = 0.0
var pathfinder : Pathfinder
var _direction : Vector2 = Vector2.ZERO
var _spot : Vector2 = Vector2.ZERO
var _has_spot : bool = false
var _spot_timer : float = 0.0

func enter() -> void:
	print("entering shoot state")
	_direction = Vector2.ZERO
	_cooldown_timer = 0.5
	_animation_finished = true 
	enemy.velocity = Vector2.ZERO
	if not enemy.animation_player.animation_finished.is_connected(_on_animation_finished):
		enemy.animation_player.animation_finished.connect(_on_animation_finished)
	pathfinder = PATHFINDER.instantiate() as Pathfinder
	enemy.add_child(pathfinder)
	_has_spot = false
	_spot_timer = 0.0			

func exit() -> void:
	print("exiting shoot state")
	if enemy.animation_player.animation_finished.is_connected(_on_animation_finished):
		enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	if is_instance_valid(pathfinder):
		pathfinder.queue_free()	

func process(_delta: float) -> EnemyState:
	_cooldown_timer -= _delta
	var dir = enemy.global_position.direction_to(enemy.player.global_position)
	enemy.set_direction(dir)
	if not _animation_finished:
		print("animation not finished")
		return null
	if PlayerManager.player.hp <= 0:
		print("player dead")
		return $"../Idle"
	var dist = enemy.global_position.distance_to(enemy.player.global_position)
	if dist > shoot_range:
		print("player out of shoot range, going chase")
		return $"../Chase"
	elif dist < enemy.attack_range:
		print("player in attack range, going attack")
		return $"../Attack"
	elif dist < runaway_range:
		print("player too close, going flee")
		return $"../Flee"
	if _cooldown_timer <= 0:
		print("cooldown 0")
		if check_los():
			print("los ok going shoot")
			_shoot()
		else:
			return _reposition(_delta)
	else:
		print("cooldown in progress going idle")
		enemy.velocity = Vector2.ZERO
		enemy.update_animation("idle")
	return null

func _on_animation_finished(_a: String) -> void:
	if not _a.begins_with(anim_name):
		return
	_animation_finished = true
	print("animation finished")
	
func _shoot() -> void:
	if not is_instance_valid(enemy.player):
		return
	_cooldown_timer = shoot_cooldown
	_animation_finished = false
	enemy.velocity = Vector2.ZERO
	# Start the attack animation
	enemy.update_animation(anim_name)
	
func spawn_spear() -> void:
	if not is_instance_valid(enemy.player):
		return
	var spear : Spear = SPEAR.instantiate()
	var origin : Vector2 = _muzzle_origin()
	var tip : Vector2 = origin + spear.get_node("HurtBox").position   # tam faktycznie jest kolizja
	var chest : Vector2 = enemy.global_position + Vector2(0, -15)
	if _blocked(chest, tip):
		spear.queue_free()   # strzała nie jest jeszcze w drzewie, więc to bezpieczne
		return               # przeszkoda tuż przy łuczniku: nie strzelaj
	var target : Vector2 = enemy.player.global_position + Vector2(0, -12)
	spear.global_position = origin
	spear.fire(tip.direction_to(target))
	enemy.add_sibling(spear)	

func _muzzle_origin() -> Vector2:
	var dir_name : String = enemy.anim_direction()
	var offset : Vector2 = MUZZLE[dir_name]
	if dir_name == "side":
		offset.x *= sign(enemy.sprite.scale.x) if enemy.sprite.scale.x != 0 else 1.0
	return enemy.global_position + offset
	
func check_los() -> bool:
	if not is_instance_valid(enemy.player):
		return false
	var tip : Vector2 = _muzzle_origin() + Vector2(2, -15)   # to samo miejsce, w którym powstaje kolizja strzały
	var target : Vector2 = enemy.player.global_position + Vector2(0, -12)
	if _blocked(enemy.global_position + Vector2(0, -15), tip):
		return false
	return not _blocked_thick(tip, target)
	
func _blocked(from: Vector2, to: Vector2) -> bool:
	var q := PhysicsRayQueryParameters2D.create(from, to, OBSTACLE_MASK)
	q.collide_with_areas = false
	q.exclude = [enemy.get_rid()]
	return not enemy.get_world_2d().direct_space_state.intersect_ray(q).is_empty()
	
func _point_free(p: Vector2) -> bool:
	var q := PhysicsPointQueryParameters2D.new()
	q.position = p
	q.collision_mask = enemy.collision_mask
	q.collide_with_areas = false
	return enemy.get_world_2d().direct_space_state.intersect_point(q, 1).is_empty()

# Szuka punktu wokół gracza, z którego go widać; wybiera najbliższy łucznikowi.
func _find_firing_spot() -> bool:
	var player_pos : Vector2 = enemy.player.global_position
	var from_player : Vector2 = enemy.global_position - player_pos
	var dist : float = clampf(from_player.length(), maxf(runaway_range + 30.0, min_spot_distance), shoot_range - 30.0)
	var base_angle : float = from_player.angle()
	var best : float = INF
	var found : bool = false
	for i in range(1, 9):
		for sgn in [-1.0, 1.0]:
			var p : Vector2 = player_pos + Vector2.from_angle(base_angle + sgn * i * deg_to_rad(22.5)) * dist
			if not _point_free(p):
				continue
			if _blocked(p + Vector2(0, -15), player_pos + Vector2(0, -12)):
				continue
			var d : float = enemy.global_position.distance_to(p)
			if d < best:
				best = d
				_spot = p
				found = true
	return found

func _reposition(delta: float) -> EnemyState:
	_spot_timer -= delta
	if not _has_spot or _spot_timer <= 0.0 or enemy.global_position.distance_to(_spot) < 8.0:
		_has_spot = _find_firing_spot()
		_spot_timer = 1.0 if _has_spot else 0.4
	if not _has_spot:
		enemy.velocity = Vector2.ZERO
		enemy.update_animation("idle")
		return null
	pathfinder.has_target = true
	pathfinder.target_pos = _spot
	_direction = lerp(_direction, pathfinder.move_dir, 0.5)
	enemy.velocity = _direction * reposition_speed
	enemy.update_animation("chase")
	return null	

# Trzy promienie (środek i dwa boki po 3 px), bo strzała ma grubość.
func _blocked_thick(from: Vector2, to: Vector2) -> bool:
	var side : Vector2 = from.direction_to(to).orthogonal() * 3.0
	return _blocked(from, to) or _blocked(from + side, to + side) or _blocked(from - side, to - side)
