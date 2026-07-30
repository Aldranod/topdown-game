@tool
class_name InteractArea extends Area2D

signal player_entered

var dialog: DialogInteraction
var is_triggered : bool = false
@onready var interact_data: PersistentDataHandler = $PersistentDataHandler

func _ready() -> void:
	_on_data_loaded()
	body_entered.connect( _on_area_enter)
	body_exited.connect( _on_area_exited)
	interact_data.data_loaded.connect( _on_data_loaded)
	for c in get_children():
		if c is DialogInteraction:
			dialog = c
			break
	pass	
		
func _on_area_enter(_p : Node2D) -> void:
	print(is_triggered)
	if is_triggered == true:
		return
	else:
		PlayerManager.interact_pressed.connect(player_interact)
		Messages.input_hint_changed.emit("interact")	
	pass	
	
func _on_data_loaded() -> void:
	is_triggered = interact_data.value	

func player_interact() -> void:
	is_triggered = true	
	player_entered.emit()
	if dialog:
		interact_data.set_value()	
		dialog.player_interact()
	interact_data.set_value()
	
func _on_area_exited( _p : Node2D ) -> void:
	PlayerManager.interact_pressed.disconnect( player_interact)
	Messages.input_hint_changed.emit("")
	pass	
