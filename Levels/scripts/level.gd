class_name  Level extends Node2D

@export var music : AudioStream
@export var cutscene : bool = false
@export var cutscene_trigger : NPC
@export var target_node : Node
@export var darkness : bool = false


func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent( self )
	LevelManager.level_load_started.connect( _free_level)
	AudioManager.play_music(music)
	if cutscene:
		play_cutscene()
	if darkness:
		PlayerManager.player.player_light_switch(true)
	else:
		PlayerManager.player.player_light_switch(false)		

func _free_level() -> void:
	PlayerManager.unparent_player( self )
	queue_free()

func player_camera_switch() -> void:
	if PlayerManager.player:
		PlayerManager.player.player_camera_switch()

func play_cutscene() -> void:
	#cutscene_camera_switch()
	if cutscene_trigger:
		for c in cutscene_trigger.get_children():
			if c is DialogInteraction:
				
				c.player_interact()		
	pass

func cutscene_camera_switch() -> void:
	if $Camera2D:
		$Camera2D.enabled = true
		$Camera2D.make_current()

func end_cutscene() -> void:
	print("ending")
	#$LevelTransition._player_entered(PlayerManager.player)
	pass

func kill_node( target_node) -> void:
	target_node.queue_free()
	pass

func hide_tree() -> void:
	pass # Replace with function body.

func show_tree() -> void:
	pass # Replace with function body.
