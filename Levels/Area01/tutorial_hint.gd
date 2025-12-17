extends Area2D

@onready var label: RichTextLabel = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export_multiline var description : String
@onready var persistent_data_handler: PersistentDataHandler = $PersistentDataHandler


# THE KEY CHANGES:
# An array to hold multiple target nodes.
@export var target_nodes: Array[NodePath]
# The name of the signal to listen for on each target node.
@export var action_signal_name: String = "plant_destroyed"
@export var pause_menu_signal : bool = false
@export var player_signal : bool = false

func _ready() -> void:
	persistent_data_handler.get_value()
	if persistent_data_handler.value == true:
		queue_free()
		return
	label.text = description
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	if pause_menu_signal:
		PauseMenu.shown.connect(_on_action_performed)
	if player_signal:
		PlayerManager.player.connect(action_signal_name, _on_action_performed)	
	# Loop through every NodePath assigned in the editor.
	for node_path in target_nodes:
		if node_path.is_empty():
			continue # Skip if a slot in the array is empty.
		var target_node = get_node(node_path)
		# Check if the node is valid and has the signal we want to listen to.
		if is_instance_valid(target_node) and target_node.has_signal(action_signal_name):
			# Connect the signal to our "action performed" function.
			target_node.connect(action_signal_name, _on_action_performed)
			# Increment our counter for each successful connection.


# This function is called every time ANY of the connected nodes emit the signal.
func _on_action_performed():
	print("saving")
	persistent_data_handler.set_value()
	animation_player.play("fade_out")
	await animation_player.animation_finished
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	# Show the hint only if the player enters the area.
	#if body.is_in_group("player"):
	animation_player.play("fade_in")

func _on_body_exited(body: Node2D) -> void:
	# Hide the hint if the player leaves the area.
	#if body.is_in_group("player"):
	animation_player.play("fade_out")
