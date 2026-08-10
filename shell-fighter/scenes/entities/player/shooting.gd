extends Node2D

signal bullet_type_changed(bullet_data: BulletData)

# Assign one .tres resource per slot in the Inspector
# (normal_bullet.tres / scatter_bullet.tres / grenade_bullet.tres)
@export var normal_bullet_data: BulletData
@export var scatter_bullet_data: BulletData
@export var grenade_bullet_data: BulletData

const muzzleDistance: float = 15

const BULLET = preload("res://scenes/entities/bullet/bullet.tscn")
var shootDirection: Vector2 = Vector2(0,1) # Should be a unit vector
var current_bullet_data: BulletData
var ammoType: int = 1

@onready var muzzle: Marker2D = $Muzzle
@onready var player: Node2D = $".."
@onready var animated_sprite_2d: AnimatedSprite2D = $Muzzle/AnimatedSprite2D
@onready var ammo_component: AmmoComponent = $"../AmmoComponent"
@onready var sfx_player_shoot: AudioStreamPlayer = $sfxPlayerShoot
@onready var sfx_ammo_switch: AudioStreamPlayer = $sfxAmmoSwitch
@onready var sfx_out_of_ammo: AudioStreamPlayer = $sfxOutOfAmmo

@onready var debug_mouse_tracker: Line2D = $DebugMouseTracker
@onready var debug_aim_tracker: Line2D = $DebugAimTracker

func _ready() -> void:
	current_bullet_data = normal_bullet_data
	bullet_type_changed.emit(current_bullet_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Get the mouse position relative to the center of the camera
	var mousePosition = get_local_mouse_position() as Vector2
	
	debug_mouse_tracker.set_point_position(1, mousePosition)
	
	# Guard against divide by zero case
	shootDirection = mousePosition.normalized() if mousePosition.length() > 0 else Vector2.RIGHT
	muzzle.position = shootDirection * muzzleDistance
	muzzle.rotation = -atan2(shootDirection.y, -shootDirection.x) + PI
	
	debug_aim_tracker.set_point_position(1, muzzle.position * 16)
	
	AssignGunTexture(muzzle.rotation)

func AssignGunTexture(angle: float):
	# Divide it into buckets of size PI/4,
	# shift it up by PI/8 so the cardinal directoins are in the center of each bucket,
	# and tuncate to get the index
	var bucket = ((angle + PI / 8) / (PI / 4)) as int % 8
	
	const texturePermutation: Array = ["gun_right", "gun_right", "gun_down", "gun_left", "gun_left", "gun_left", "gun_up", "gun_right"]
	
	if bucket in [5, 6, 7]:
		muzzle.z_index = 2
	else:
		muzzle.z_index = 4
	
	animated_sprite_2d.play(texturePermutation[bucket])

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot()
	
	var previous_bullet_data := current_bullet_data
	
	if Input.is_action_just_pressed("selectNormalAmmo"):
		current_bullet_data = normal_bullet_data
		ammoType = 1
		if (sfx_ammo_switch != null):
			sfx_ammo_switch.play()
	elif Input.is_action_just_pressed("selectSpreadAmmo"):
		current_bullet_data = scatter_bullet_data
		ammoType = 2
		if (sfx_ammo_switch != null):
			sfx_ammo_switch.play()
	elif Input.is_action_just_pressed("selectGernadeAmmo"):
		current_bullet_data = grenade_bullet_data
		ammoType = 3
		if (sfx_ammo_switch != null):
			sfx_ammo_switch.play()
		
	if Input.is_action_just_pressed("selectAmmoLeft"):
		ammoType = ammoType - 1
		if (sfx_ammo_switch != null):
			sfx_ammo_switch.play()
	elif Input.is_action_just_pressed("selectAmmoRight"):
		ammoType = ammoType + 1
		if (sfx_ammo_switch != null):
			sfx_ammo_switch.play()
	
	if ammoType < 1:
		ammoType = 3
	elif ammoType > 3:
		ammoType = 1
		
	if ammoType == 1:
		current_bullet_data = normal_bullet_data
	elif ammoType == 2:
		current_bullet_data = scatter_bullet_data
	elif ammoType == 3:
		current_bullet_data = grenade_bullet_data
	
	# Only fire the signal when the equipped type actually changed, since this
	# block re-runs on every _input() call (including mouse motion), not just
	# on the select/cycle presses.
	if current_bullet_data != previous_bullet_data:
		bullet_type_changed.emit(current_bullet_data)


func shoot():
	if not current_bullet_data:
		return
	if not ammo_component.try_use_ammo(current_bullet_data):
		if(sfx_out_of_ammo != null):
			sfx_out_of_ammo.play()
		return
		
	randomize()
	
	print("[shoot] using %s (path: %s) dmg=%d shots=%d" % [
		current_bullet_data.resource_name if current_bullet_data.resource_name else "unnamed",
		current_bullet_data.resource_path if current_bullet_data.resource_path else "EMBEDDED/NO PATH",
		current_bullet_data.damage,
		current_bullet_data.shot_count
	])
	
	var baseDirection = shootDirection * current_bullet_data.speed
	
	for _i in range(current_bullet_data.shot_count):
		if (sfx_player_shoot != null):
			sfx_player_shoot.play()
		
		var newBullet = BULLET.instantiate()
		
		newBullet.position = muzzle.position + player.position
		newBullet.rotation = muzzle.rotation
		
		# Add to the tree first so the bullet's @onready vars (sprite, etc.) are
		# resolved before we touch them in setup()
		player.add_sibling(newBullet)
		newBullet.setup(current_bullet_data)
		
		# Rotate the bullet randomly based on spread
		var theta = randf_range(-current_bullet_data.spread, current_bullet_data.spread)
		var bulletDirection = Vector2(
			baseDirection.dot(Vector2(cos(theta), -sin(theta))),
			baseDirection.dot(Vector2(sin(theta),  cos(theta)))
		)
		
		newBullet.get_node(NodePath("RigidBody2D")).apply_force(bulletDirection)
