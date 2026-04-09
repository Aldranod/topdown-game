extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func setup(data: CorpseData, scale_x: float, pose: float) -> void:
	sprite.texture = data.corpse_texture
	sprite.position = data.sprite_offset
	sprite.hframes = data.hframes
	sprite.vframes = data.vframes
	sprite.frame = data.frame
	sprite.scale.x = scale_x
	sprite.rotation = pose	
