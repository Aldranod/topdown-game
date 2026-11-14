#extends Sprite2D
#
#var attack_sprite : Sprite2D
#var anim : AnimationPlayer
#
#func _ready() -> void:
	#if not (get_parent() is Player):
		#set_process(false)   # smuga z dasha: nic nie rób
		#return
	#attack_sprite = $"../Sprite2DAttack"
	#anim = $"../AnimationPlayer"
#
#func _process(_delta: float) -> void:
	#if anim == null or attack_sprite == null:
		#return
	#var a : String = anim.current_animation
	#var use_attack : bool = a.begins_with("attack")
	#self_modulate.a = 0.0 if use_attack else 1.0
	#attack_sprite.visible = use_attack
	#attack_sprite.scale.x = scale.x	

extends Sprite2D

@export var hold_time : float = 0.12   # jak długo sprite ataku zostaje po zakończeniu ciosu

var attack_sprite : Sprite2D
var anim : AnimationPlayer
var _hold : float = 0.0

func _ready() -> void:
	if not (get_parent() is Player):
		set_process(false)   # smuga z dasha: nic nie rób
		return
	attack_sprite = $"../Sprite2DAttack"
	anim = $"../AnimationPlayer"

func _process(delta: float) -> void:
	if anim == null or attack_sprite == null:
		return
	if anim.assigned_animation.begins_with("attack"):
		_hold = hold_time
	else:
		_hold = maxf(_hold - delta, 0.0)
	var use_attack : bool = _hold > 0.0
	self_modulate.a = 0.0 if use_attack else 1.0
	attack_sprite.visible = use_attack
	attack_sprite.scale.x = scale.x
