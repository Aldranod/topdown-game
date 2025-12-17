class_name HurtBox extends Area2D

signal did_damage

@export var damage : int = 1
@export var attack_type: String = ""

func _ready():
	area_entered.connect( AreaEntered )
	
func AreaEntered( a : Area2D) -> void:
	if a is HitBox:
		did_damage.emit()
		a.TakeDamage( self)
	pass		
