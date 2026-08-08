extends Node2D

const muzzleDistance: float = 20
const bulletVelocityMagnitude: float = 20

const BULLET = preload("res://scenes/entities/bullet/bullet.tscn")
var shootDirection: Vector2 = Vector2(0,1) # Should be a unit vector

@onready var muzzle: Marker2D = $Muzzle
@onready var player: Node2D = $".."
@onready var sprite: Sprite2D = $Muzzle/Sprite2D

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
	
	sprite.frame = textureIndex(muzzle.rotation)

func textureIndex(angle: float):
	# Divide it into buckets of size PI/4,
	# shift it up by PI/8 so the cardinal directoins are in the center of each bucket,
	# and tuncate to get the index
	var bucket = ((angle + PI / 8) / (PI / 4)) as int % 8
	
	print(bucket)
	const texturePermutation: Array = [16, 16, 17, 18, 18, 18, 17, 16]
	return texturePermutation[bucket]

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot()

func shoot():
	var newBullet = BULLET.instantiate()
	
	newBullet.position = muzzle.position + player.position
	newBullet.rotation = muzzle.rotation
	
	newBullet.get_node(NodePath("RigidBody2D")).apply_force(shootDirection * bulletVelocityMagnitude)
	player.add_sibling(newBullet)
