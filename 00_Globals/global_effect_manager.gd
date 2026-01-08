extends Node

const DAMAGE_TEXT = preload("res://00_Globals/global_effects/damage_text.tscn")
const HITSPARK : PackedScene = preload("res://00_Globals/global_effects/hitspark.tscn")
const DUST = preload("res://00_Globals/global_effects/dust.tscn")

func damage_text(_damage : int, _pos : Vector2) -> void:
	var _t : DamageText = DAMAGE_TEXT.instantiate()
	_t.global_position = _pos
	add_child(_t)
	_t.start(str(_damage),_pos)
	pass
	
func frame_freeze(timescale : float, duration: float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration * timescale).timeout
	Engine.time_scale = 1.0
	pass

func emit_dust() -> void:
	var _d = DUST.instantiate()
	_d.global_position = PlayerManager.player.position + Vector2(0,-5)
	get_tree().current_scene.add_child(_d)
	var anim_name : String = "default"
	_d.play_animation(anim_name)
	pass

func set_hitspark(target : String, _pos : Vector2, _boss : bool = false, _dir : Vector2 = Vector2.ZERO, ) -> void:
	var hitspark = HITSPARK.instantiate()
	hitspark.global_position = _pos
	get_tree().current_scene.add_child(hitspark)
	var anim_name : String = "default"
	var player = PlayerManager.player
	if target == "enemy":
		if _boss == true:
			hitspark.global_position.x = _pos.x
			hitspark.global_position.y = _pos.y -20
		if player.cardinal_direction == Vector2.LEFT or player.cardinal_direction == Vector2.RIGHT :
			anim_name = "default"   
			var flip : bool = player.cardinal_direction == Vector2.RIGHT
			hitspark.set_flipped(flip)
		else: 
			anim_name = "vertical"
			var flip : bool = player.cardinal_direction == Vector2.DOWN
			hitspark.set_flipped_v(flip)
	elif target == "player":
		if abs(_dir.x) > abs(_dir.y):
			if _dir.x > 0:
				anim_name = "default"
			else:
				anim_name = "default"
				var flip = true
				hitspark.set_flipped(flip)
		else:
			if _dir.y > 0:
				anim_name = "vertical"
			else:
				anim_name = "vertical"
				var flip = true
				hitspark.set_flipped_v(flip)											
	hitspark.play_animation(anim_name)

func rain(_v: bool) -> void:
	if _v == true:
		PlayerManager.player.rain.emitting = true
	else:
		PlayerManager.player.rain.emitting = false	
	pass
