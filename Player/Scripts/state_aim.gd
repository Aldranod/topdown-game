class_name State_Aim extends State

@onready var idle: State = $"../Idle"
@onready var aim_sprite: Sprite2D = $"../../AimPivot/AimSprite"

func Enter() -> void:
	print("ENTERING AIM STATE")
	player.velocity = Vector2.ZERO
	player.UpdateAnimation("idle")

func Exit() -> void:
	aim_sprite.visible = false
	player.aim_sprite_visible = false
	print("EXITING AIM STATE")
	
func Process(delta: float) -> State:
	aim_sprite.visible = true
	player.aim_sprite_visible = true
	return null

func HandleInput(_event: InputEvent) -> State:
	var trigger_strength = Input.get_action_strength("ability")
	if trigger_strength > 0.7 and player.arrow_count > 0:
		print("ENTERING BOW STATE")
		return $"../Bow"
	else:
		return $"../Idle"
	return null
