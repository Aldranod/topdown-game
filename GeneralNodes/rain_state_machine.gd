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
			state = NoRain.new(get_parent().particle)
			
		if event.pressed and event.keycode == KEY_2:
			state = Drizzle.new(get_parent().particle)
			
		if event.pressed and event.keycode == KEY_3:
			state = HeavyRain.new(get_parent().particle)		
	pass
