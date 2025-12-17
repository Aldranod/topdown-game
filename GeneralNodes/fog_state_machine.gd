extends Node

@export var debug : bool = true

var state: WeatherState = null:
	set(value):
		if state != null:
			state.exit()
			
		state = value
		state.enter()	

func _input(event):
	if event is InputEventKey and debug:
		if event.pressed and event.keycode == KEY_1:
			state = Fog.new(get_parent().color_rect)
			
		if event.pressed and event.keycode == KEY_2:
			state = NoFog.new(get_parent().color_rect)
			
	pass
