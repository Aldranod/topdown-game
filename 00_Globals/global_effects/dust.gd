extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
	
func play_animation(anim_name : String) -> void:
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	else:
		animation_player.play("default")
	await animation_player.animation_finished
	queue_free()
	pass
	
