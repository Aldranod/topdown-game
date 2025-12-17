extends Node

signal level_load_started
signal level_loaded
signal TileMapBoundsChanged( bounds: Array[ Vector2])

signal time_tick(time:float)

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

var INGAME_SPEED = 0.7
var INITIAL_HOUR = 12

var time : float =0.0
var past_minute: float = -1.0

var current_tilemap_bounds : Array[ Vector2]
var target_transition : String
var position_offset : Vector2

func _ready() -> void:
	time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR
	await get_tree().process_frame
	level_loaded.emit()

func _process(delta: float) -> void:
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	var value =(sin(time - PI /2) + 1.0) / 2.0
	_recalculate_time()
	pass

func ChangeTilemapBounds(bounds: Array[ Vector2]) -> void:
	current_tilemap_bounds = bounds
	TileMapBoundsChanged.emit( bounds )

func load_new_level(
		level_path : String,
		_target_transition : String,
		_position_offset : Vector2
) -> void:
	
	get_tree().paused = true
	target_transition = _target_transition
	position_offset = _position_offset
	await SceneTransition.fade_out()
	level_load_started.emit()
	await get_tree().process_frame
	get_tree().change_scene_to_file( level_path	)
	@warning_ignore("redundant_await")
	await SceneTransition.fade_in()
	get_tree().paused = false
	await get_tree().process_frame
	level_loaded.emit()
	
	pass

func _recalculate_time() -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	#if past_minute != minute:
		#past_minute = minute
		#time_tick.emit(time)
	time_tick.emit(time)	
	pass
