class_name AmbushArea extends Area2D

func _ready() -> void:
	body_entered.connect( _on_area_enter)
	pass	
		
func _on_area_enter(_p : Node2D) -> void:
	if _p is Player:
		var e = get_parent()
		if e is Enemy:
			e.exit_ambush()
		queue_free()	
	pass	
