extends Node
var open : bool = false
@onready var is_open: PersistentDataHandler = $is_open

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_if_open()

func check_if_open() -> void:
	open = is_open.value
	if open:
		queue_free()
