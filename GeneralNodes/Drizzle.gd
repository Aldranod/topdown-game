extends RainState
class_name Drizzle

var emitter: GPUParticles2D

func _init(particle_emitter):
	emitter = particle_emitter
	
func enter():
	emitter.process_material = load("res://GeneralNodes/Drizzle.tres")
	emitter.emitting = true
	emitter.amount = 1500
	
func exit():
	emitter.process_material = null
	emitter.emitting = false	
