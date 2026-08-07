extends Node2D

const muzzleDistance: float = 60

var bullet = preload("res://scenes/dev/bullet.tscn")

@onready var muzzle: Marker2D = $Muzzle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Get the mouse position relative to the center of the camera
	var mousePosition = get_viewport().get_mouse_position() as Vector2i - get_window().size / 2
	# Set the muzzle position to be a constant displacement away in the direction of the mouse
	muzzle.position = mousePosition / sqrt(mousePosition.x**2 + mousePosition.y**2) * muzzleDistance

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot()

func shoot():
	var newBullet = bullet.instantiate()
	newBullet.position = muzzle.position
	add_child(newBullet)
