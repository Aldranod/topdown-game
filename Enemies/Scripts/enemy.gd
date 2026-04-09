class_name Enemy extends CharacterBody2D

signal direction_changed( new_direction : Vector2)
signal enemy_damaged( hurt_box : HurtBox )
signal enemy_destroyed( hurt_box : HurtBox )

const DIR_4 = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
const CORPSE = preload("res://Enemies/corpse.tscn")

@export var hp : int = 3
@export var xp_reward : int = 1 
@export var respawnable : bool = true
@export var attack_range : float = 24.0
@export var corpse_data: CorpseData = null

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var player : Player
var invulnerable : bool = false
var sprite_x_scale : float = 1

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var hit_box : HitBox = $HitBox
@onready var hurt_box: HurtBox = $HurtBox
@onready var state_machine : EnemyStateMachine = $EnemyStateMachine
@onready var persistent_data_handler: PersistentDataHandler = $PersistentDataHandler

var distance_in_pixel : float
var initial_position

func _ready():
	sprite_x_scale = sprite.scale.x
	var enemy_id = get_tree().current_scene.name + "_" + name
	if respawnable:
		# Check our temporary list
		if SaveManager.check_enemy_death(enemy_id):
			queue_free()
			return
	else:
		persistent_data_handler.get_value()
		if persistent_data_handler.value == true:
			queue_free()
	state_machine.initialize(self)
	player = PlayerManager.player
	hit_box.Damaged.connect( _take_damage )
	pass

func _process(_delta):
	pass	

func _physics_process(_delta):
	initial_position = global_position
	move_and_slide()
	dust_emit()

func set_direction( _new_direction : Vector2) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false
		
	var direction_id : int = int( round(
		 ( direction + cardinal_direction * 0.1).angle()
		 / TAU * DIR_4.size()
	) )
	var new_dir = DIR_4[ direction_id]
		
	if new_dir ==  cardinal_direction:
		return false
		
	cardinal_direction = new_dir
	direction_changed.emit(new_dir)
	sprite.scale.x = -sprite_x_scale if cardinal_direction == Vector2.LEFT else sprite_x_scale
	return true

func update_animation( state : String ) -> void:
	var anim_name = state + "_" + anim_direction()
	if anim_name:
		animation_player.play( anim_name)
	pass	
	
func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
		
func _take_damage( hurt_box : HurtBox ) -> void:
	if invulnerable == true:
		return
	if hurt_box.attack_type == "sword":
		EffectManager.set_hitspark("enemy", global_position)
	hp -= hurt_box.damage		
	PlayerManager.shake_camera(hurt_box.damage)	
	EffectManager.damage_text(hurt_box.damage, global_position + Vector2(0,-36))
	EffectManager.frame_freeze(0.1,0.26)	
	if hp > 0:
		enemy_damaged.emit( hurt_box)	
	else:
		var enemy_id = get_tree().current_scene.name + "_" + name
		if respawnable:
			# Tell the manager this specific enemy is dead for now
			SaveManager.add_enemy_death(enemy_id)
		else:
			# Permanent death
			persistent_data_handler.set_value()
		enemy_destroyed.emit( hurt_box )
		_spawn_corpse(enemy_id)
		#queue_free() # or whatever your death logic is
		#enemy_destroyed.emit( hurt_box)
		#persistent_data_handler.set_value()	
		
func _in_attack_range() -> bool:
	return is_instance_valid(PlayerManager.player) and global_position.distance_to(PlayerManager.player.position) <= attack_range		

func dust_emit() -> void:
	distance_in_pixel += global_position.distance_to(initial_position)
	if distance_in_pixel >= 68:
		distance_in_pixel -= 68
		EffectManager.emit_dust(self)
	pass

func can_shoot() -> bool:
	if $EnemyStateMachine.has_node("Shoot"):
		print("shoot node found")
		var shoot_state = $EnemyStateMachine/Shoot
		var dist = global_position.distance_to(player.global_position)
		if dist > attack_range and dist > shoot_state.runaway_range and dist <= shoot_state.shoot_range:
			if shoot_state.check_los():
				return true
	else:
		return false		
	return false

func clear_collisions() -> void:
	for c in get_children():
		if c is CollisionShape2D:
			c.queue_free()
	pass
	
func exit_ambush() -> void:
	$EnemyStateMachine/Idle.in_ambush = false
	pass	

func _spawn_corpse(enemy_id: String) -> void:
	if corpse_data == null:
		return
	var corpse = CORPSE.instantiate()
	var level = get_tree().current_scene
	level.add_child(corpse)
	corpse.global_position = global_position
	var pose = 0
	if cardinal_direction == Vector2.DOWN:
		pose = randf_range(130.0,230.0)
	if cardinal_direction == Vector2.UP:
		pose = randf_range(-57.0,57.0)
	if cardinal_direction == Vector2.LEFT:
		pose = randf_range(-40.0,-126.0)
	if cardinal_direction == Vector2.RIGHT:
		pose = randf_range(40.0,126.0)			
	corpse.setup(corpse_data, sprite.scale.x, pose)
	SaveManager.add_corpse(
		enemy_id,
		global_position.x,
		global_position.y,
		sprite.scale.x,
		corpse_data.resource_path  # store .tres path for restoration
	)
