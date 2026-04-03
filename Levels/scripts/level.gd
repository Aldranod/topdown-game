class_name  Level extends Node2D

enum WeatherType { None, HeavyRain, Fog, NoFog, Drizzle }

@export var music : AudioStream
@export var cutscene : bool = false
@export var cutscene_trigger : NPC
@export var darkness : bool = false

var weather_map : Dictionary = {}
#$CanvasModulate
@export_group("Weather Settings")
@export var weather_active : bool = false
@export var storm : bool = false
@export var weather_layer_1: WeatherType = WeatherType.None
@export var weather_layer_2: WeatherType = WeatherType.None

const CORPSE = preload("res://Enemies/corpse.tscn")
#@export var weather : bool = false
#@export var weather_mod1: WEATHER
#@export var weather_mod2: WEATHER
#@export var weather_mod3: WEATHER

func _ready() -> void:
	weather_map = {
		WeatherType.HeavyRain: HeavyRain,
		WeatherType.Fog: Fog,
		WeatherType.NoFog: NoFog,
		WeatherType.Drizzle: Drizzle
	}
	self.y_sort_enabled = true
	PlayerManager.set_as_parent( self )
	LevelManager.level_load_started.connect( _free_level)
	AudioManager.play_music(music)
	play_cutscene()
	darkness_check()
	weather_check()
	#LevelManager.time_tick.connect(lightning)
	start_lightning_loop()
	_restore_corpses()

func start_lightning_loop() -> void:
	while storm:
		# 1. Calculate random wait time
		var wait_time = randf_range(10.0, 45.0)	
		# 2. Wait for that time
		await get_tree().create_timer(wait_time).timeout
		# 3. Trigger Lightning
		await lightning()
	
func lightning() -> void:
	var tween = create_tween()
	tween.tween_property($Weather/CanvasModulate, "color", Color(1, 1, 1, 1), 0.2)
	tween.tween_property($Weather/CanvasModulate, "color", Color8(184, 185, 218), 0.3)
	pass
		
func play_cutscene() -> void:
	if cutscene:
		if cutscene_trigger:
			for c in cutscene_trigger.get_children():
				if c is DialogInteraction:
					c.player_interact()	
	else:
		return

func darkness_check() -> void:
	if darkness:
		PlayerManager.player.player_light_switch(true)
	else:
		PlayerManager.player.player_light_switch(false)
	pass

func weather_check() -> void:
	if not weather_active:
		return	
	_apply_weather_from_enum(weather_layer_1)
	_apply_weather_from_enum(weather_layer_2)

func _apply_weather_from_enum(type_enum: WeatherType) -> void:
	# If "None" is selected, do nothing
	if type_enum == WeatherType.None:
		return
		
	# Look up the script in the dictionary
	if weather_map.has(type_enum):
		var script_to_load = weather_map[type_enum]
		# Pass the SCRIPT to the manager (exactly what it expects)
		%WeatherManager.change_to(script_to_load)
	else:
		print("Error: Weather type not found in map for enum value: ", type_enum)

func _free_level() -> void:
	PlayerManager.unparent_player( self )
	queue_free()

func player_camera_switch() -> void:
	if PlayerManager.player:
		PlayerManager.player.player_camera_switch()

func cutscene_camera_switch() -> void:
	if $Camera2D:
		$Camera2D.enabled = true
		$Camera2D.make_current()

func end_cutscene() -> void:
	print("ending")
	#$LevelTransition._player_entered(PlayerManager.player)
	pass

func kill_node(target_node : Node) -> void:
	target_node.queue_free()
	pass

func hide_tree() -> void:
	pass # Replace with function body.

func show_tree() -> void:
	pass # Replace with function body.
	
func _restore_corpses() -> void:
	var scene_prefix = name + "_"
	for data in SaveManager.get_corpses():
		if not data.id.begins_with(scene_prefix):
			continue
		var corpse_data = load(data.scene_path) as CorpseData
		if corpse_data == null:
			continue
		var corpse = CORPSE.instantiate()
		add_child(corpse)
		corpse.global_position = Vector2(data.pos_x, data.pos_y)
		corpse.setup(corpse_data, data.scale_x)
