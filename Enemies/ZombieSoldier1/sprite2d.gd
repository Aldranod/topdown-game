extends Sprite2D

@export var hold_time : float = 0.0   # u wroga zwykle 0; podnieś, jeśli chcesz, by cios został chwilę po animacji

var attack_sprite : Sprite2D
var anim : AnimationPlayer
var _hold : float = 0.0

func _ready() -> void:
	attack_sprite = $"../Sprite2DAttack"
	anim = $"../AnimationPlayer"
	attack_sprite.visible = false

func _process(delta: float) -> void:
	if anim == null or attack_sprite == null:
		return
	if anim.assigned_animation.begins_with("attack"):
		_hold = hold_time
	else:
		_hold = maxf(_hold - delta, 0.0)
	var use_attack : bool = _hold > 0.0 or anim.assigned_animation.begins_with("attack")
	self_modulate.a = 0.0 if use_attack else 1.0
	attack_sprite.visible = use_attack
	attack_sprite.scale.x = scale.x
