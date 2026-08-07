extends Node2D

# TODO: Consider making bullets expire when they go off the screen rather than if a duration expires
const timeToLive: float = 3

@onready var rigid_body_2d: RigidBody2D = $RigidBody2D
@onready var timeLived = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timeLived += delta
	if timeLived >= timeToLive:
		queue_free()
