class_name NotesSystemNode extends CanvasLayer

signal shown
signal hidden

var is_active : bool = false
@onready var content: RichTextLabel = $Control/PanelContainer/RichTextLabel
@onready var control: Control = $Control
var note: NoteData

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_note()
	pass

func _unhandled_input(event: InputEvent) -> void:
	if is_active == false:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		hide_note()
	pass
	
func hide_note() -> void:
	get_tree().paused = false
	control.visible = false
	is_active = false
	PlayerManager.reset_camera_on_player()
	hidden.emit()
	pass		

func show_note(note) -> void:
	get_tree().paused = true
	control.visible = true
	content.text = note.content
	is_active = true
	shown.emit()
	pass	
