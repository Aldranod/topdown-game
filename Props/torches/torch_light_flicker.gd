extends PointLight2D

@export var energy_variation := 0.12
@export var scale_variation := 0.05
@export var sway := 3.0          # px, lekkie "pływanie" światła
@export var speed := 0.6

var _noise := FastNoiseLite.new()
var _t := 0.0
var _base_energy := 1.0
var _base_scale := 1.0
var _base_pos := Vector2.ZERO

func _ready() -> void:
	_noise.seed = randi()
	_noise.frequency = 1.0
	_base_energy = energy
	_base_scale = texture_scale
	_base_pos = position

func _process(delta: float) -> void:
	_t += delta * speed
	energy = _base_energy + _noise.get_noise_1d(_t * 3.0) * energy_variation
	texture_scale = _base_scale * (1.0 + _noise.get_noise_1d(_t * 2.0 + 50.0) * scale_variation)
	position = _base_pos + Vector2(
		_noise.get_noise_1d(_t + 100.0),
		_noise.get_noise_1d(_t + 200.0)
	) * sway
