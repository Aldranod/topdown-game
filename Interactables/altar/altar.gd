extends Node2D

@export var power_type: String = "Sword_upgrade"
@onready var interact_area: Area2D = $Area2D
@onready var is_used_data: PersistentDataHandler = $IsUsed

func _ready() -> void:
	is_used_data.get_value()
	if is_used_data.value == true:
		modulate = Color("blue")
		interact_area.monitoring = false
	else:	
		interact_area.area_entered.connect( _on_area_enter)
		interact_area.area_exited.connect( _on_area_exit)
		Messages.altar_used.connect(altar_used)
		
func _on_area_enter( _p : Area2D) -> void:
	PlayerManager.interact_pressed.connect( use_altar)
	Messages.input_hint_changed.emit("interact")
	pass
		
func _on_area_exit( _p : Area2D) -> void:
	PlayerManager.interact_pressed.disconnect( use_altar)
	Messages.input_hint_changed.emit("")
	pass
	
func use_altar() -> void:
	if PlayerManager.is_max_level(power_type):
		print("Ta moc osiągnęła już limit!")
		# Opcjonalnie: odtwórz dźwięk błędu lub pokaż dymek nad ołtarzem
		return
	else:
		PlayerManager.player.animation_player.play("pray")
		await get_tree().create_timer(0.5).timeout
		AltarMenu.configure(power_type, self)
	pass	

func altar_used() -> void:
	print("player in range")
	is_used_data.set_value()
	modulate = Color.DIM_GRAY
	interact_area.monitoring = false
