class_name HitBox extends Area2D

signal Damaged( hurt_box : HurtBox  )

func TakeDamage ( hurt_box : HurtBox ) -> void:
	Damaged.emit( hurt_box )
	Input.start_joy_vibration(0, 0.5, 0.5, 0.2)
	
