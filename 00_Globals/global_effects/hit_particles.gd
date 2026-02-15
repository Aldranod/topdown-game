class_name HitParticles extends GPUParticles2D

func start( dir : Vector2, settings : HitParticleSettings) -> void:
	if settings:
		amount = settings.count
		modulate = settings.color
		texture = settings.texture
	emitting = true
	await finished
	queue_free()
	pass
