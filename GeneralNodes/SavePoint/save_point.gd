class_name SavePoint extends Node2D

@onready var label_animation_player: AnimationPlayer = $Label/LabelAnimationPlayer
@onready var interact_area: Area2D = $Area2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
var particles : ParticleProcessMaterial
signal bonfire_used

func _ready() -> void:
	gpu_particles_2d.emitting = false
	particles = gpu_particles_2d.process_material as ParticleProcessMaterial
	interact_area.area_entered.connect( _on_area_enter)
	interact_area.area_exited.connect( _on_area_exit)
	pass
	
func _on_area_enter( _a : Area2D) -> void:
	PlayerManager.interact_pressed.connect( player_interact)
	pass
		
	
func _on_area_exit( _a : Area2D) -> void:
	PlayerManager.interact_pressed.disconnect( player_interact)
	pass
	
func player_interact() -> void:
	bonfire_used.emit()
	label_animation_player.play("saved")
	gpu_particles_2d.amount = 50
	gpu_particles_2d.explosiveness = 1
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 100
	gpu_particles_2d.emitting = true
	await get_tree().create_timer(0.5).timeout
	gpu_particles_2d.amount = 10
	gpu_particles_2d.explosiveness = 1
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30
	SaveManager.save_game()
	pass	
		
