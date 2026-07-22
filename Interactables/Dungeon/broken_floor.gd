class_name BtokenFloor extends Node2D

var is_broken : bool = false
@export var broke_audio : AudioStream
@export_file( "*.tscn") var level
@export var target_transition_area : String = "LevelTransition"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var is_broken_data: PersistentDataHandler = $PersistentDataHandler
@onready var interact_area: Area2D = $InteractArea2D

func _ready() -> void:
	interact_area.body_entered.connect( _player_entered)
	is_broken_data.data_loaded.connect( set_state )
	set_state()
	if is_broken == true:
		$Sprite2D.visible = true
	else:
		$Sprite2D.visible = false	
	
func _player_entered( _p : Node2D) -> void:
	if PlayerManager.player.state_machine.current_state is State_Dash:
			return
	else:		
		if is_broken:
			LevelManager.load_new_level( level, target_transition_area, Vector2(0,460))	
		else:
			is_broken = true
			is_broken_data.set_value()
			audio.stream = broke_audio
			$Sprite2D.visible = true
			await get_tree().physics_frame
			await get_tree().physics_frame
			LevelManager.load_new_level( level, target_transition_area, Vector2(0,460))			
	pass
	
func set_state() -> void:
	is_broken = is_broken_data.value
		
