extends CanvasLayer
@onready var textcontainer: RichTextLabel = $AltarMenu/PanelContainer/RichTextLabel
var required_trophy : int
var _power: String
var currency : ItemData = preload("res://items/gem.tres")
var is_active : bool = false	
var used_altar_node: Node2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_menu()

func configure(power: String, altar_ref: Node2D ) -> void:
	required_trophy = PlayerManager.get_upgrade_cost(power)
	_power = power
	used_altar_node = altar_ref
	textcontainer.text = "Would you like to sacrifice " + str(required_trophy) + " trophies ?"
	show_menu()
	pass

func _on_yes_pressed() -> void:
	var can_purchase : bool = get_item_quantity(currency) >= required_trophy
	if can_purchase:
		$AltarMenu/VBoxContainer.visible = false
		textcontainer.text = "God of Wrath accepted your offering!"
		print(_power+" granted!")
		grant_power()
		pass
	else:
		textcontainer.text = "You don't have enough thropies!"
		# hide buttons
		await get_tree().create_timer(1).timeout
		hide_menu()
		pass	

func _on_no_pressed() -> void:
	hide_menu()

func get_item_quantity(item : ItemData) -> int:
	return PlayerManager.INVENTORY_DATA.get_item_held_quantity(item)
	
func show_menu() -> void:
	enable_menu()
	$AltarMenu/VBoxContainer.get_child(0).grab_focus()
	#play_audio(ALTAR)
	pass
	
func hide_menu() -> void:
	enable_menu(false)
	pass
	
func enable_menu( _enabled : bool = true) -> void:
	get_tree().paused = _enabled
	visible = _enabled
	$AltarMenu/VBoxContainer.visible = _enabled
	is_active = _enabled		

func grant_power() -> void:
	var inv : InventoryData = PlayerManager.INVENTORY_DATA
	inv.use_item(currency, required_trophy)
	if _power == "attack":
		PlayerManager.player.attack += 1
		PlayerManager.player.update_damage_values()
	if _power == "Bow_upgrade":
		print("bow upgraded")
	if _power == "Dash_upgrade":
		print("dash upgraded")
	used_altar_node.altar_used()
	SaveManager.save_player_stats()	
	await get_tree().create_timer(1).timeout
	hide_menu()	
