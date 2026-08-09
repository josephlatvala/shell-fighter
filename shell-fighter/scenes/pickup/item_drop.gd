extends Node

const AMMO_PICKUP = preload("res://scenes/pickup/AmmoPickup.tscn")

@export var min_drop: int = 1
@export var max_drop: int = 1
@export var min_distance: int = 0
@export var max_distance: int = 40
@export var possible_bullet_data: Array[BulletData] = []

@onready var parent = $".."
@onready var health_component = $"../HealthComponent"

func _ready():
	health_component.connect("died", _on_died)

func _on_died() -> void:
	print("[item_drop] dropping item %s from %s" % [
		"ammo",
		parent.name,
	])
	
	if possible_bullet_data.size() <= 0:
		push_error("no possible drops for item_drop under %s" % [parent.name])
		return
		
	for _i in range(randi_range(min_drop, max_drop)):
		var bullet_data = possible_bullet_data.pick_random()
		var new_pickup = AMMO_PICKUP.instantiate()
		
		# Random magnitude and direciton away
		var theta = randf_range(0, 2 * PI)
		var base_offset = Vector2(0, randi_range(min_distance, max_distance))
		var position_offset = Vector2(
			base_offset.dot(Vector2(cos(theta), -sin(theta))),
			base_offset.dot(Vector2(sin(theta),  cos(theta)))
		)
		
		new_pickup.position = position_offset + parent.position
		new_pickup.bullet_data = bullet_data
		parent.add_sibling.call_deferred(new_pickup)


func _on_health_component_died() -> void:
	pass # Replace with function body.
