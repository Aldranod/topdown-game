@tool
class_name LevelTransitionInteract extends LevelTransition
signal level_transitioned

@export var is_open : bool = true
@export var key_item : ItemData # What item open this door
@export var locked_audio : AudioStream
@export var open_audio : AudioStream
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var is_open_data: PersistentDataHandler = $PersistentDataHandler
@onready var label_animation_player: AnimationPlayer = $Label/LabelAnimationPlayer
@export var interaction_text : bool = false
@export var message : String = ""

func _ready() -> void:
	super()
	area_entered.connect( _on_area_entered)
	area_exited.connect( _on_area_exited)
	if not is_open:
		set_state()
	
func player_interact() -> void:
	if is_open:
		level_transitioned.emit()
		_player_entered(PlayerManager.player)
	else:
		if key_item == null:
			return
		var door_unlocked = PlayerManager.INVENTORY_DATA.use_item( key_item)
		if door_unlocked:
			audio.stream = open_audio
			audio.play()
			await get_tree().create_timer(0.5).timeout
			is_open_data.set_value()
			set_state()
			level_transitioned.emit()
			_player_entered(PlayerManager.player)
		else:
			audio.stream = locked_audio
			if interaction_text:
				$Label.text = message
				label_animation_player.play("locked")	
		audio.play()		
	pass	
	
func _on_area_entered( _a: Area2D ) -> void:
	PlayerManager.interact_pressed.connect( player_interact)
	Messages.input_hint_changed.emit("interact")
	pass
	
func _on_area_exited( _a: Area2D ) -> void:
	PlayerManager.interact_pressed.disconnect( player_interact)
	Messages.input_hint_changed.emit("")
	pass	

func _update_area() -> void:
	super()
	collision_shape.shape.size = Vector2(32,32)

func set_state() -> void:
	is_open = is_open_data.value
	
