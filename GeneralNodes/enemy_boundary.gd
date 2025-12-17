extends StaticBody2D
@onready var boundary_data: PersistentDataHandler = $PersistentDataHandler

func _ready() -> void:
	boundary_data.get_value()
	if boundary_data.value == true:
		queue_free()
	pass

func kill() -> void:
	boundary_data.set_value()
	queue_free()
	pass
