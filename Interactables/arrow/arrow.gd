class_name Arrow extends Node2D

@export var move_speed : float = 300
@export var fire_audio: AudioStream = preload("res://Player/Audio/bow_fire.wav")

var move_dir : Vector2 = Vector2.RIGHT

@onready var hurt_box: HurtBox = $HurtBox
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var wall_detector: Area2D = $WallDetector

func _ready() -> void:
	rotate_nodes()
	hurt_box.did_damage.connect( _on_did_damage)
	wall_detector.body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_exit)
	if fire_audio:
		audio_stream_player_2d.stream = fire_audio
		audio_stream_player_2d.play()
	pass

func _process(delta: float) -> void:
	position += move_dir * delta * move_speed
	pass
	
func fire( fire_dir: Vector2 ) -> void:
	move_dir = fire_dir
	rotate_nodes()
	show()
	pass	

func rotate_nodes() -> void:
	var s1 = get_node_or_null("Sprite2D")
	var s2 = get_node_or_null("Sprite2D2")
	var hb = get_node_or_null("HurtBox")
	var pl = get_node_or_null("PointLight2D")
	var wd = get_node_or_null("WallDetector")
	var angle = move_dir.angle()
	if s1: s1.rotation = angle
	if s2: s2.rotation = angle
	if hb: hb.rotation = angle
	if pl: pl.rotation = angle
	if wd: wd.rotation = angle 
	pass	
		
func _on_did_damage() -> void:
	queue_free()
	pass	
	
func _on_exit() -> void:
	queue_free()
	pass	

func _on_body_entered(body: Node2D) -> void:
	# Hits anything on layer 5 — trees, buildings, regular walls
	queue_free()
