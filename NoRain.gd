extends RainState
class_name  NoRain

var emitter: GPUParticles2D

func _init(particle_emitter):
	emitter = particle_emitter
	
func enter():
	emitter.process_material = null
	emitter.emitting = false

func exit():
	pass
