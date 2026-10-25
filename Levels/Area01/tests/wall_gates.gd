extends Area2D

var dialog: DialogInteraction
@onready var is_open: PersistentDataHandler = $PersistentDataHandler

func _ready() -> void:
	if is_open.value:
		$"../Props/BarredDoor8".open()
	area_entered.connect( _on_area_entered)
	area_exited.connect( _on_area_exited)
	for c in get_children():
		if c is DialogInteraction:
			dialog = c
			break
	
func player_interact() -> void:
	if is_open.value:
		return
	else:
		var door_unlocked = true
		if door_unlocked:
			is_open.set_value()
			$"../Props/BarredDoor8".open_door()
			$CollisionShape2D.queue_free()
		else:
			if dialog:
				dialog.player_interact()	

func _on_area_entered( _a: Area2D ) -> void:
	PlayerManager.interact_pressed.connect(player_interact)
	Messages.input_hint_changed.emit("interact")
	pass
	
func _on_area_exited( _a: Area2D ) -> void:
	PlayerManager.interact_pressed.disconnect( player_interact)
	Messages.input_hint_changed.emit("")
	pass	
