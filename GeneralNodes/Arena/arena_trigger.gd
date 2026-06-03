class_name ArenaTrigger extends Area2D
@export var interact_trigger : bool = false

func _ready() -> void:
	body_entered.connect( _on_area_enter)
	pass	
		
func _on_area_enter(_p : Node2D) -> void:
	if _p is Player:
		if interact_trigger:
			PlayerManager.interact_pressed.connect( player_interact)
		else:
			Messages.arena_entered.emit()	
	pass

func player_interact() -> void:
	Messages.arena_entered.emit()
	pass	
	
	
