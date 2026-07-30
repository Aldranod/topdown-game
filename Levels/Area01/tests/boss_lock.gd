extends Area2D

@onready var boss_killed: PersistentDataHandler = $PersistentDataHandler
var doors_closed: bool = false

func _ready() -> void:
	body_entered.connect( _on_area_entered)
	$"../Props/BarredDoor4".open()
	if boss_killed.value:
		$"../Props/BarredDoor9".open()
	pass

func _on_area_entered( _p: Node2D ) -> void:
	if _p is Player:
		if boss_killed.value or doors_closed:
			return
		else:	
			doors_closed = true	
			$"../Props/BarredDoor4".close_door()
	pass
