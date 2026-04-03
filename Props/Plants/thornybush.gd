class_name ThornyBush extends Node2D

signal plant_destroyed
var is_choped : bool = false
@export var particles: Array [HitParticleSettings ]
@export var hp: float = 3
@export var fixed_hit_count: bool = false
@onready var is_choped_data: PersistentDataHandler = $IsChoped
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	$HitBox.Damaged.connect( TakeDamage )
	set_plant_state()

func set_plant_state() -> void:
	is_choped = is_choped_data.value
	if is_choped:
		queue_free()

func TakeDamage( _damage : HurtBox ) -> void:
	var _direction = global_position.direction_to(_damage.global_position)
	for p in particles:
		EffectManager.hit_particles($HitBox.global_position,-_direction,p)
	var rand = randi_range(0,1)
	if rand == 0:	
		animation_player.play("hit")
	else:	
		animation_player.play("hit_2")
	await animation_player.animation_finished	
	if fixed_hit_count:
		hp -= 1
	else:
		hp -= _damage.damage
	if hp <= 0:
		Destroy()		
	pass

	
func Destroy() ->void:
	plant_destroyed.emit()
	clear_collisions()
	animation_player.play("destroy")
	await animation_player.animation_finished
	is_choped_data.set_value()
	queue_free()
	pass

func clear_collisions() -> void:
	for c in get_children():
		if c is StaticBody2D:
			c.queue_free()
	pass
