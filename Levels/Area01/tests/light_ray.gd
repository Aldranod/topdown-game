extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func hide_self() ->void:
	visible = true
	pass
	
func show_self() ->void:
	visible = false
	pass	
