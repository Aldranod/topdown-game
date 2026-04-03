extends GPUParticles2D


func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		global_position = camera.global_position
