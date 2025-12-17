class_name EnemySpawner extends  Node2D

signal enemy_spawned
@export var enemy : PackedScene
var is_spawned: bool = false
@onready var enemy_data: PersistentDataHandler = $PersistentDataHandler

func _ready() -> void:
	enemy_data.data_loaded.connect( _on_data_loaded)
	_on_data_loaded()
	
func spawn_enemy() -> void:
	print("received")
	if is_spawned == true:
		return
	is_spawned = true
	var ENEMY1 = enemy.instantiate() as Enemy
	call_deferred("add_child", ENEMY1)
	enemy_spawned.emit()
	enemy_data.set_value()		
	
func _on_data_loaded() -> void:
	is_spawned = enemy_data.value
