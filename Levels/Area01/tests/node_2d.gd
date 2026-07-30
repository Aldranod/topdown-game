extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $"../LevelTransitionInteract".is_open == true:
		queue_free()
	pass # Replace with function body.
