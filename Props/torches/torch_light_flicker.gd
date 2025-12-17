extends PointLight2D

func _ready() -> void:
	flicker()
	
func flicker() -> void:
	if not is_inside_tree():
		return
	else:	
		energy = randf() * 0.1 + 0.9
		scale = Vector2(1,1) * energy
		await get_tree().create_timer(0.1333).timeout
		flicker()
	pass	
