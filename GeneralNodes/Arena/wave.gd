class_name ArenaWave extends Node

@export var enemies : Array[PackedScene]
var markers: Array[Marker2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_markers()
	pass # Replace with function body.

func release_enemies() -> void:
	var enemies_node = $"../../Enemies"
	var marker : int = 0
	for enemy in enemies:
		var ENEMY : Enemy = enemy.instantiate()
		ENEMY.add_to_group("arenaminion")
		enemies_node.add_child(ENEMY)
		ENEMY.global_position = markers[marker].global_position
		print("enemy "+ str(marker) + " instantiated on position: " + str(ENEMY.position))
		marker += 1
		ENEMY.enemy_destroyed.connect(_on_enemy_died)
		#enemies_node.call_deferred("add_child", ENEMY)
	pass
	
func get_markers() -> void:
	for m in $"..".get_children():
		if m is Marker2D:
			markers.append(m)
	pass

func _on_enemy_died(hurt_box : HurtBox) -> void:
	# Remove from tracking array
	enemies.erase(enemies.pick_random())
	# Check if wave is cleared
	if enemies.is_empty():
		await get_tree().process_frame
		Messages.arena_wave_cleared.emit()  # Global signal
		
