class_name ForestTree extends Node2D

@export var collision : bool = true
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
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
