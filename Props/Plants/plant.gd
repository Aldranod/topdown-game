class_name Plant extends Node2D
signal plant_destroyed

var is_choped : bool = false

const PICKUP = preload("res://items/item_pickup/item_pickup.tscn")
@export var drops : Array[DropData]

@onready var is_choped_data: PersistentDataHandler = $IsChoped
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	$HitBox.Damaged.connect( TakeDamage )
	$Throwable.destroyed.connect( Destroy )
	set_plant_state()

func set_plant_state() -> void:
	is_choped = is_choped_data.value
	if is_choped:
		queue_free()

func TakeDamage( _damage : HurtBox ) -> void:
	plant_destroyed.emit()
	animation_player.play("destroy")
	await animation_player.animation_finished
	is_choped_data.set_value()
	drop_items()
	queue_free()
	pass
	
func Destroy() ->void:
	plant_destroyed.emit()
	animation_player.play("destroy")
	await animation_player.animation_finished
	is_choped_data.set_value()
	drop_items()
	queue_free()
	pass
		
func drop_items() -> void:
	if drops.size() == 0:
		return
	for i in drops.size():
		if drops[i] == null or drops[i].item == null:
			continue
		var drop_count : int = drops[i].get_drop_count()
		for j in drop_count:
			var drop :ItemPickup = PICKUP.instantiate() as ItemPickup
			drop.item_data = drops[i].item
			#get_parent().call_deferred("add_child", drop)
			get_parent().add_child(drop)
			drop.global_position = global_position
			#drop.velocity = velocity.rotated(randf_range(-1.5, 1.5)) * randf_range(0.9, 1.5)
			#drop.velocity = Vector2(randi_range(-2, 1), randi_range(1, 2))
	pass	
