class_name  Level extends Node2D

@export var music : AudioStream
@export var cutscene : bool = false
@export var cutscene_trigger : NPC
@export var darkness : bool = false
@export var weather : bool = false

func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent( self )
	LevelManager.level_load_started.connect( _free_level)
	AudioManager.play_music(music)
	play_cutscene()
	darkness_check()
	weatcher_check()
		
func play_cutscene() -> void:
	if cutscene:
		if cutscene_trigger:
			for c in cutscene_trigger.get_children():
				if c is DialogInteraction:
					c.player_interact()	
	else:
		return

func darkness_check() -> void:
	if darkness:
		PlayerManager.player.player_light_switch(true)
	else:
		PlayerManager.player.player_light_switch(false)
	pass
	
func weatcher_check() -> void:
	if weather:
		$WeatherManager.change_to(HeavyRain)	
		$WeatherManager.change_to(Fog)	
	else:
		return	

func _free_level() -> void:
	PlayerManager.unparent_player( self )
	queue_free()

func player_camera_switch() -> void:
	if PlayerManager.player:
		PlayerManager.player.player_camera_switch()

func cutscene_camera_switch() -> void:
	if $Camera2D:
		$Camera2D.enabled = true
		$Camera2D.make_current()

func end_cutscene() -> void:
	print("ending")
	#$LevelTransition._player_entered(PlayerManager.player)
	pass

func kill_node(target_node : Node) -> void:
	target_node.queue_free()
	pass

func hide_tree() -> void:
	pass # Replace with function body.

func show_tree() -> void:
	pass # Replace with function body.
