class_name BossStateCallHelp extends EnemyState

@export var enemies : Array[PackedScene]
@export var next_state: EnemyState
@export var spawn_delay_between : float = 0.1
@export var spawn_delay_after : float = 0.5
@export var anim_name : String = "call_help"

var markers: Array[Marker2D]
var enemies_spawned: bool = false
var _spawning_in_progress: bool = false

func enter() -> void:
	$"../../Sprite2D/AttackHurtBox".monitoring = false	
	$"../../Label".text = "Call Help"
	enemies_spawned = false
	_spawning_in_progress = true
	markers.assign(get_tree().get_nodes_in_group("bossmarker"))
	# Validate before spawning
	if markers.size() == 0:
		push_error("No boss markers found in scene!")
		enemies_spawned = true
		_spawning_in_progress = false
		return
	if enemies.size() == 0:
		push_error("No enemies assigned to spawn!")
		enemies_spawned = true
		_spawning_in_progress = false
		return
	
	# Start spawning
	enemy.update_animation(anim_name)
	await enemy.animation_player.animation_finished
	#await get_tree().create_timer(1.0).timeout
	await release_enemies()
	
func process(_delta: float) -> EnemyState:
	if enemies_spawned and not _spawning_in_progress:
		return next_state
	return null
	
func exit() -> void:
	# Don't reset if we're still spawning
	$"../../Sprite2D/AttackHurtBox".monitoring = true	
	if not _spawning_in_progress:
		enemies_spawned = false
	
func release_enemies() -> void:
	# Find the Enemies node
	var enemies_node = get_tree().root.find_child("Enemies", true, false)
	if not is_instance_valid(enemies_node):
		push_error("Could not find 'Enemies' node in scene tree!")
		enemies_spawned = true
		_spawning_in_progress = false
		return
	var marker_index : int = 0
	for enemy_scene in enemies:
		# Check if we have enough markers
		if marker_index >= markers.size():
			push_warning("Not enough markers for all enemies! Wrapping around.")
			marker_index = 0
		# Instantiate enemy
		var enemy_instance : Enemy = enemy_scene.instantiate()
		if not is_instance_valid(enemy_instance):
			push_error("Failed to instantiate enemy!")
			continue
		# Get spawn position BEFORE adding to tree
		var spawn_position = markers[marker_index].global_position
		# Add to group
		enemy_instance.add_to_group("bossminion")
		print("Spawning enemy ", marker_index, " at position: ", spawn_position)
		# Add to scene tree first
		enemies_node.add_child(enemy_instance)
		# Set position AFTER adding to tree (now global_position works correctly)
		enemy_instance.global_position = spawn_position
		print("Enemy ", marker_index, " actual position after spawn: ", enemy_instance.global_position)
		marker_index += 1
		# Small delay between spawns for visual effect
		if marker_index < enemies.size():
			await get_tree().create_timer(spawn_delay_between).timeout
	# Wait a bit before transitioning
	await get_tree().create_timer(spawn_delay_after).timeout
	# Verify enemies actually spawned
	var spawned_minions = get_tree().get_nodes_in_group("bossminion")
	print("Total minions spawned: ", spawned_minions.size())
	enemies_spawned = true
	_spawning_in_progress = false
