class_name SavePoint extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label_animation_player: AnimationPlayer = $Label/LabelAnimationPlayer
@onready var interact_area: Area2D = $Area2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var is_lit_data: PersistentDataHandler = $IsLit
@onready var point_light_2d: PointLight2D = $PointLight2D
var bonfire_lit : bool = false
var particles : ParticleProcessMaterial
#signal bonfire_used

func _ready() -> void:
	set_bonfire_state()
	if bonfire_lit:
		animation_player.play("lit")
		point_light_2d.enabled = true
	gpu_particles_2d.emitting = false
	particles = gpu_particles_2d.process_material as ParticleProcessMaterial
	interact_area.area_entered.connect( _on_area_enter)
	interact_area.area_exited.connect( _on_area_exit)
	pass
	
func _on_area_enter( _a : Area2D) -> void:
	PlayerManager.interact_pressed.connect( save)
	Messages.input_hint_changed.emit( "interact")
	pass
		
func _on_area_exit( _a : Area2D) -> void:
	PlayerManager.interact_pressed.disconnect( save)
	Messages.input_hint_changed.emit( "")
	pass
	
func save() -> void:
	#bonfire_used.emit()
	label_animation_player.play("saved")
	label_animation_player.seek(0)
	if not bonfire_lit:
		animation_player.play("firing")
		animation_player.play("lit")
		point_light_2d.enabled = true
	gpu_particles_2d.emitting = true
	await get_tree().create_timer(0.5).timeout
	is_lit_data.set_value()
	SaveManager.save_game()
	pass	
		
func set_bonfire_state() -> void:
	bonfire_lit = is_lit_data.value
