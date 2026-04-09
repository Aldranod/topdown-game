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
		if a.get_parent().is_in_group("enemies") or a.get_parent().is_in_group("breakables"):
			EffectManager.set_hitspark("enemy",a.global_position,false, PlayerManager.player.direction)
	pass		
