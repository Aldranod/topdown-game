@tool
class_name TriggerArea extends Area2D

signal player_entered

var dialog: DialogInteraction
var is_triggered : bool = false
@onready var trigger_data: PersistentDataHandler = $PersistentDataHandler

func _ready() -> void:
	_on_data_loaded()
	body_entered.connect( _on_area_enter)
	trigger_data.data_loaded.connect( _on_data_loaded)
	for c in get_children():
		if c is DialogInteraction:
			dialog = c
			break
	pass	
		
func _on_area_enter(_p : Node2D) -> void:
	print(is_triggered)
	if is_triggered == true:
		return
	is_triggered = true	
	player_entered.emit()
	if dialog:
		trigger_data.set_value()	
		dialog.player_interact()
	trigger_data.set_value()
	pass	
	
func _on_data_loaded() -> void:
	is_triggered = trigger_data.value	
