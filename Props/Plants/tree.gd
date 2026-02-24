class_name ForestTree extends Node2D

@export var collision : bool = true
@export var particles: Array[HitParticleSettings]
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	$HitBox.Damaged.connect( TakeDamage )
	$HitBox2.Damaged.connect( TakeDamage2 )
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
	if visible:	
		var _direction = global_position.direction_to(_damage.global_position)
		EffectManager.hit_particles($HitBox.global_position,-_direction,particles[0])
	pass
	
func TakeDamage2( _damage : HurtBox ) -> void:
	if visible:		
		var _direction = global_position.direction_to(_damage.global_position)
		var offset_distance = 20.0  # Small distance offset
		var particle_position = _damage.global_position + (-_direction * offset_distance)
		EffectManager.hit_particles(particle_position,-_direction,particles[1])
	pass	
