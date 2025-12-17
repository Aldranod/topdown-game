class_name Shopkeeper extends Node2D

@export var shop_inventory : Array[ItemData]
@onready var dialog_branch_yes: DialogBranch = $NPC/QuestActivatedSwitch/DialogInteraction/DialogChoice/DialogBranch
@onready var dialog_branch_yes2: DialogBranch = $NPC/QuestActivatedSwitch2/DialogInteraction/DialogChoice/DialogBranch

func _ready() -> void:
	dialog_branch_yes.selected.connect( show_shop_menu)
	dialog_branch_yes2.selected.connect( show_shop_menu)
	pass
	
func show_shop_menu() -> void:
	ShopMenu.show_menu(shop_inventory)
	pass
		
