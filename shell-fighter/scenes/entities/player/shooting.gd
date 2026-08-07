extends Node2D

const muzzleDistance: float = 60
const bulletVelocityMagnitude: float = 20

const BULLET = preload("res://scenes/entities/bullet/bullet.tscn")
var shootDirection: Vector2 = Vector2(0,1) # Should be a unit vector

@onready var muzzle: Marker2D = $Muzzle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Get the mouse position relative to the center of the camera
	var mousePosition = get_viewport().get_mouse_position() as Vector2i - get_window().size / 2
	
	shootDirection = mousePosition / sqrt(mousePosition.x**2 + mousePosition.y**2)
	muzzle.position = shootDirection * muzzleDistance
	muzzle.rotation = atan(shootDirection.y / shootDirection.x)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot()

func shoot():
	var newBullet = BULLET.instantiate()
	
	newBullet.position = muzzle.position
	newBullet.rotation = muzzle.rotation
	
	newBullet.get_node(NodePath("RigidBody2D")).apply_force(shootDirection * bulletVelocityMagnitude)
	# TODO: make this not a child of the player (position should be aboslute from here on out)
	add_child(newBullet)
