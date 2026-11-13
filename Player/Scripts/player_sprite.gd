#extends Sprite2D
#
#const FRAME_COUNT :int= 435
#
#@onready var weapon_below: Sprite2D = $Sprite2D_Weapon_Below
#@onready var weapon_above: Sprite2D = $Sprite2D_Weapon_Above
#@onready var attack_sprite : Sprite2D
#@onready var anim : AnimationPlayer
#
#func _ready() -> void:
	#if not (get_parent() is Player):
		#set_process(false)   # smuga z dasha: nic nie rób
		#return
	#attack_sprite = $"../Sprite2DAttack"
	#anim = $"../AnimationPlayer"	
	#PlayerManager.INVENTORY_DATA.equipment_changed.connect(_on_equipment_change)
	#pass
	#
#func _process(_delta: float) -> void:
	#if anim == null or attack_sprite == null:
		#return
	#var a : String = anim.current_animation
	#var use_attack : bool = a.ends_with("_side") and a.begins_with("attack")
	#self_modulate.a = 0.0 if use_attack else 1.0
	#attack_sprite.visible = use_attack
	#attack_sprite.scale.x = scale.x   # kopiuj odwrócenie w lewo
	#pass
	#
#func _on_equipment_change() -> void:
	#var equipment : Array[SlotData] = PlayerManager.INVENTORY_DATA.equipment_slots()
	#texture = equipment[0].item_data.sprite_texture
	#weapon_below.texture = equipment[1].item_data.sprite_texture
	#weapon_above.texture = equipment[1].item_data.sprite_texture
	#pass	

extends Sprite2D

var attack_sprite : Sprite2D
var anim : AnimationPlayer

func _ready() -> void:
	if not (get_parent() is Player):
		set_process(false)   # smuga z dasha: nic nie rób
		return
	attack_sprite = $"../Sprite2DAttack"
	anim = $"../AnimationPlayer"

func _process(_delta: float) -> void:
	if anim == null or attack_sprite == null:
		return
	var a : String = anim.current_animation
	var use_attack : bool = a.begins_with("attack")
	self_modulate.a = 0.0 if use_attack else 1.0
	attack_sprite.visible = use_attack
	attack_sprite.scale.x = scale.x	
