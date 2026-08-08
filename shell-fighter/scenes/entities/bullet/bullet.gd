extends Node2D

@export var timeToLive: float = 0
@export var damage: int = 0

@onready var rigid_body_2d: RigidBody2D = $RigidBody2D
@onready var area_2d: Area2D = $RigidBody2D/Area2D
@onready var timeLived = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered) # Connect area 2d object with function
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timeLived += delta
	if timeLived >= timeToLive:
		queue_free()

# Called when an Area node intersects with the bullet.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var health_component := body.get_node_or_null("HealthComponent") as HealthComponent
		if health_component:
			health_component.take_damage(damage)
		queue_free()
