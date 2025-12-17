extends Node

@export var particle: GPUParticles2D
@export var color_rect : ColorRect

@onready var rain_state_machine: Node = $RainStateMachine
@onready var fog_state_machine: Node = $FogStateMachine

func _ready() -> void:
	#change_to(Drizzle)
	#change_to(Fog)
	pass

func change_to(new_state):
	if new_state.type == "Rain":
		rain_state_machine.state = new_state.new(particle)
	elif new_state.type == "Fog":
		fog_state_machine.state = new_state.new(color_rect)	

func change_to_list(list_of_states):
	for state in list_of_states:
		change_to(state)
