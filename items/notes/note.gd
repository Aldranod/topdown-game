class_name NoteItem extends Node2D

@export var note_data : NoteData
@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	pass

func player_interact() -> void:
	NotesMenu.show_note(note_data)
	pass

func _on_body_entered(body: Node2D) -> void:
	PlayerManager.interact_pressed.connect( player_interact)
	animation_player.play("show")
	pass
	
func _on_body_exited(body: Node2D) -> void:
	PlayerManager.interact_pressed.disconnect( player_interact)
	animation_player.play("hide")
	pass	
