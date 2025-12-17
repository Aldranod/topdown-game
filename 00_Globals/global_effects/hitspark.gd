extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
	
func play_animation(anim_name : String) -> void:
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	else:
		animation_player.play("default")
	animation_player.animation_finished.connect(_on_anim_finished)		
	pass

func _on_anim_finished(_anim_name) -> void:
	queue_free()	

func set_flipped(flipped: bool) -> void:
	if sprite:
		sprite.flip_h = flipped
		#sprite.offset.x = 8
	else:
		print("[Hitspark] Sprite2D node not found!")
		
func set_flipped_v(flipped: bool) -> void:
	if sprite:
		sprite.flip_v = flipped
		#sprite.offset.y = -8
	else:
		print("[Hitspark] Sprite2D node not found!")		
