extends Sprite2D

func _ready() -> void:
	set_instance_shader_parameter("RandomStrength", randf_range(-5.0,5.0))
