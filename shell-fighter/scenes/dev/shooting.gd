extends Node2D

@onready var muzzle: Marker2D = $Muzzle

var muzzleDistance: float = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mousePosition = get_viewport().get_mouse_position() as Vector2i - get_window().size / 2
	muzzle.position = mousePosition / sqrt(mousePosition.x**2 + mousePosition.y**2) * muzzleDistance
