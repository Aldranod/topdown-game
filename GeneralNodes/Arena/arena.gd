class_name Arena extends Node

var waves : Array[ArenaWave]
var current_wave : int = 0
var arena_started : bool = false
@onready var arena_completed: PersistentDataHandler = $PersistentDataHandler
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arena_completed.get_value()
	if arena_completed.value == true:
		queue_free()
	Messages.arena_entered.connect(_on_arena_entered)
	Messages.arena_wave_cleared.connect(_on_arena_wave_cleared)
	get_waves()
	pass # Replace with function body.

func _on_arena_entered() -> void:
	lock_arena()
	if not arena_started:
		arena_started = true
		await get_tree().create_timer(1).timeout
		waves[current_wave].release_enemies()
	pass

func _on_arena_wave_cleared() -> void:
	current_wave += 1
	if current_wave >= waves.size():
		arena_completed.set_value()
		queue_free()
	else:
		await get_tree().create_timer(0.5).timeout
		waves[current_wave].release_enemies()
	pass

func lock_arena() -> void:
	for c in get_children():
		if c is StaticBody2D:
			var cs = c.get_child(0)
			cs.set_deferred("disabled", false)
	pass				

func get_waves() -> void:
	for c in get_children():
		if c is ArenaWave:
			waves.append(c)
	pass		
