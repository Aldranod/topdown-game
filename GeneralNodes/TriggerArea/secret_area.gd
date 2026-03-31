class_name SecretArea extends Area2D

func _ready() -> void:
	body_entered.connect( _on_area_enter)
	body_exited.connect( _on_area_exited)
	pass	
		
func _on_area_enter(_p : Node2D) -> void:
	if _p is Player or _p.is_in_group("enemies"):
		for c in get_children():
			if c.is_in_group("hidable"):
				c.hide_self()
	pass	
	
func _on_area_exited(_p : Node2D) -> void:
	if _p is Player or _p.is_in_group("enemies"):
		for c in get_children():
			if c.is_in_group("hidable"):
				c.show_self()
	pass
