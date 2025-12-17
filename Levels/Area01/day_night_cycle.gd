extends CanvasModulate

@onready var day_night_cycle: CanvasModulate = $"."
@export var gradient: GradientTexture1D

func _ready() -> void:
	LevelManager.time_tick.connect(set_lighting)
	pass

func set_lighting(time:float) -> void:
	var value =(sin(time - PI /2) + 1.0) / 2.0
	color = gradient.gradient.sample(value)
	pass
