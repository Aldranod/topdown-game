extends Node

func _ready() -> void:
	#get_tree().paused = true
	PlayerManager.player.visible = false
	PlayerManager.process_mode = Node.PROCESS_MODE_DISABLED
	PlayerHud.visible = false
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	#$GPUParticles2D.emitting = true
