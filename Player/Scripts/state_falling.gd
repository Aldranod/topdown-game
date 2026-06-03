class_name State_Falling extends State

@export_range(1,20,0.5) var decelerate_speed : float = 5.0
@export var fall_speed : float = 0.0
@export var dmg: int = 1
@onready var idle: State_Idle = $"../Idle"
@onready var death: State_Death = $"../Death"
@onready var effect_animation_player: AnimationPlayer = $"../../EffectAnimationPlayer"
var next_state: State = null	
@onready var fall_box: Area2D = $"../../FallBox"

func init() -> void:
	pass	
	
func Enter() -> void:
	fall_box.monitoring = false
	next_state = null
	$"../../Label2".text = "falling"
	player.set_collision_mask_value(8, false)
	player.UpdateAnimation("fall")
	player.animation_player.animation_finished.connect(fall_completed, CONNECT_ONE_SHOT)
	#move player to previous location
	pass
	
func Exit() -> void:
	player.set_collision_mask_value(8, true)
	fall_box.monitoring = true
	pass
	
func Process(_delta: float) -> State:
	player.velocity = Vector2.ZERO
	return next_state

func Physics(_delta: float) -> State:
	return null	

func HandleInput(_delta: InputEvent) -> State:
	return null						

func fall_completed(anim_name: String) -> void:
	player.global_position = player.dash_start_position
	player.modulate =  Color(1, 1, 1, 1)
	player.update_hp( -dmg)
	effect_animation_player.play("damaged", CONNECT_ONE_SHOT)
	#player.animation_player.animation_finished.disconnect( fall_completed)
	if player.hp <= 0:
		next_state = death
	else:
		next_state = idle		
	pass
