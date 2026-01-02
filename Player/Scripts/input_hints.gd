class_name InputHints extends Node2D

const HINT_MAP : Dictionary = {
	"keyboard" : {
		"interact" :16,
		"attack":15,
		"inv_open":14
	},
	"playstation" : {
		"interact" :2,
		"attack":1,
		"inv_open":4
	},
	"xbox" : {
		"interact" :7,
		"attack":5,
		"inv_open":17
	}
}

@onready var sprite_2d: Sprite2D = $Sprite2D

var controller_type : String = "keyboard"

func _ready() -> void:
	visible = false
	Messages.input_hint_changed.connect( _on_hint_changed)
	pass 

func _input( event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		controller_type = "keyboard"
	elif event is InputEventJoypadButton:
		get_controller_type( event.device)
		
	pass

func get_controller_type( device_id : int) -> void:
	var n : String = Input.get_joy_name(device_id).to_lower()
	if "xbox" in n:
		controller_type = "xbox"
	elif "playstation" in n or "ps" in n or "dualsense" in n:
		controller_type = "playstation"
	else:
		controller_type = "xbox"	
	set_process_input(false)			
	pass
	

func _on_hint_changed( hint : String) -> void:
	if hint == "" :
		visible = false
	else: 
		visible = true	
		sprite_2d.frame = HINT_MAP[controller_type].get(hint, "0")
	pass
