extends Node2D

signal inv_open

func _process(delta: float) -> void:
	if Input.is_action_pressed("pause"):
		await get_tree().process_frame
		inv_open.emit
		print("inv_open")
	pass
