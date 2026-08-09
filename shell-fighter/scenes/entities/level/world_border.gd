@tool
extends StaticBody2D
class_name WorldBorder

## Size of the playable area (width, height), centered on this node's origin.
@export var world_size: Vector2 = Vector2(640, 360):
	set(value):
		world_size = value
		_rebuild()

## Thickness of the boundary walls (in pixels).
@export var wall_thickness: float = 16.0:
	set(value):
		wall_thickness = value
		_rebuild()

func _ready() -> void:
	# Layer 2 (enemies) + Layer 3 (player) - both entities' collision_mask
	# need to see this layer for the walls to actually block them.
	collision_layer = 6
	collision_mask = 0
	_rebuild()

func _rebuild() -> void:
	if not is_inside_tree():
		return

	for child in get_children():
		child.queue_free()

	var half_w := world_size.x / 2.0
	var half_h := world_size.y / 2.0
	var t := wall_thickness

	_add_wall("Top",    Vector2(0, -half_h - t / 2.0), Vector2(world_size.x + t * 2, t))
	_add_wall("Bottom", Vector2(0,  half_h + t / 2.0), Vector2(world_size.x + t * 2, t))
	_add_wall("Left",   Vector2(-half_w - t / 2.0, 0), Vector2(t, world_size.y))
	_add_wall("Right",  Vector2( half_w + t / 2.0, 0), Vector2(t, world_size.y))

func _add_wall(wall_name: String, wall_position: Vector2, wall_size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = wall_size

	var collision := CollisionShape2D.new()
	collision.name = wall_name
	collision.shape = shape
	collision.position = wall_position

	add_child(collision)
	if Engine.is_editor_hint() and get_tree() and get_tree().edited_scene_root:
		collision.owner = get_tree().edited_scene_root
