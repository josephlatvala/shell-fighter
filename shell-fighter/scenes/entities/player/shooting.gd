extends Node2D


# TODO: Consider making these depend on a selectable gun
const muzzleDistance: float = 15
const bulletVelocityMagnitude: float = 100
const bulletTimeToLive: float = 0.3
const bulletDamage: int = 10
const bulletShotCount: int = 3
const bulletSpread: float = PI * 0.01


const BULLET = preload("res://scenes/entities/bullet/bullet.tscn")
var shootDirection: Vector2 = Vector2(0,1) # Should be a unit vector

@onready var muzzle: Marker2D = $Muzzle
@onready var player: Node2D = $".."
@onready var animated_sprite_2d: AnimatedSprite2D = $Muzzle/AnimatedSprite2D
@onready var ammo_component: AmmoComponent = $"../AmmoComponent"

@onready var debug_mouse_tracker: Line2D = $DebugMouseTracker
@onready var debug_aim_tracker: Line2D = $DebugAimTracker


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Get the mouse position relative to the center of the camera
	var mousePosition = get_local_mouse_position() as Vector2i
	
	debug_mouse_tracker.set_point_position(1, mousePosition)
		
	shootDirection = mousePosition / sqrt(mousePosition.x**2 + mousePosition.y**2)
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
		
	print(muzzle.z_index)
	
	animated_sprite_2d.play(texturePermutation[bucket])

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot()

func shoot():
	if not ammo_component.try_use_ammo():
		return
		
	randomize()
	
	var baseDirection = shootDirection * bulletVelocityMagnitude
	
	for _i in range(bulletShotCount):
		var newBullet = BULLET.instantiate()
		
		newBullet.position = muzzle.position + player.position
		newBullet.rotation = muzzle.rotation
		
		newBullet.damage = bulletDamage
		newBullet.timeToLive = bulletTimeToLive
		
		# Rotate the bullet randomly based on spread
		var theta = randf_range(-bulletSpread, bulletSpread)
		var bulletDirection = Vector2(
			baseDirection.dot(Vector2(cos(theta), -sin(theta))),
			baseDirection.dot(Vector2(sin(theta),  cos(theta)))
		)
		
		newBullet.get_node(NodePath("RigidBody2D")).apply_force(bulletDirection)
		player.add_sibling(newBullet)
