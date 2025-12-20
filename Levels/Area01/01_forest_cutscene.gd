class_name Level1Custscene extends Node2D

@export var music : AudioStream
@export var cutscene : bool = false
@export var cutscene_trigger : NPC
@export var target_node : Node

const START_LEVEL : String = "res://Levels/Area01/01_forest1.tscn"

func _ready() -> void:
	PlayerManager.player.visible = false
	self.y_sort_enabled = true
	PlayerManager.set_as_parent( self )
	LevelManager.level_load_started.connect( _free_level)
	AudioManager.play_music(music)
	if cutscene:
		#$GPUParticles2D.emitting = true
		play_cutscene()

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
	PlayerManager.player.visible = true
	print("ending")
	#$LevelTransition._player_entered(PlayerManager.player)
	LevelManager.load_new_level(START_LEVEL,"LevelTransition2",Vector2(0,128))
	pass

func kill_node( target_node) -> void:
	target_node.queue_free()
	pass

func hide_tree() -> void:
	pass # Replace with function body.

func show_tree() -> void:
	pass # Replace with function body.
