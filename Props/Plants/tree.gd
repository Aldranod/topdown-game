class_name ForestTree extends Node2D

@export var collision : bool = true
@export var particle_settings : HitParticleSettings
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	$HitBox.Damaged.connect( TakeDamage )
	if not collision:
		remove_collision()
	pass
	
func remove_collision() -> void:
	if static_body_2d:
		static_body_2d.queue_free()
	pass	

func hide_self() ->void:
	animation_player.play("hide")
	visible = false
	pass
	
func show_self() ->void:
	animation_player.play("show")
	visible = true
	pass	
	
func TakeDamage( _damage : HurtBox ) -> void:	
	var _direction = global_position.direction_to(_damage.global_position)
	EffectManager.hit_particles($HitBox.global_position,-_direction,particle_settings)
	pass
