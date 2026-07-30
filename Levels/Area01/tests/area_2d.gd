extends Area2D
@export var doors: String
var dialog: DialogInteraction


func _ready() -> void:
	if $is_open.value:
		$ShopTilemapLayer.queue_free()
		$CollisionShape2D.queue_free()
	area_entered.connect( _on_area_entered)
	area_exited.connect( _on_area_exited)
	for c in get_children():
		if c is DialogInteraction:
			dialog = c
			break
	
func player_interact() -> void:
	if $is_open.value:
		return
	else:
		if dialog:
			dialog.player_interact()	
		$is_open.set_value()
		$ShopTilemapLayer.queue_free()
		$CollisionShape2D.queue_free()
		if not SaveManager.check_persistent_value(doors):
			SaveManager.add_persistent_value(doors)	

func _on_area_entered( _a: Area2D ) -> void:
	PlayerManager.interact_pressed.connect(player_interact)
	Messages.input_hint_changed.emit("interact")
	pass
	
func _on_area_exited( _a: Area2D ) -> void:
	PlayerManager.interact_pressed.disconnect( player_interact)
	Messages.input_hint_changed.emit("")
	pass	
