#extends Node2D
#
## Set these in each enemy's specific corpse scene in the editor
#@export var corpse_texture: Texture2D
#@export var sprite_offset: Vector2 = Vector2(0, -13)
#@export var hframes: int = 1
#@export var vframes: int = 1
#@export var frame: int = 0
#
#@onready var sprite: Sprite2D = $Sprite2D
#
#func _ready() -> void:
	#sprite.texture = corpse_texture
	#sprite.position = sprite_offset
	#sprite.hframes = hframes
	#sprite.vframes = vframes
	#sprite.frame = frame
#
#func apply_facing(scale_x: float) -> void:
	#sprite.scale.x = scale_x
	#sprite.rotation = randf_range(0,360)
	
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func setup(data: CorpseData, scale_x: float) -> void:
	sprite.texture = data.corpse_texture
	sprite.position = data.sprite_offset
	sprite.hframes = data.hframes
	sprite.vframes = data.vframes
	sprite.frame = data.frame
	sprite.scale.x = scale_x
	sprite.rotation = randf_range(0,360)	
