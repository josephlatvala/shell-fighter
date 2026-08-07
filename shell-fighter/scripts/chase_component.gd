extends Node
class_name ChaseComponent

@export var speed: float = 120.0

var target: Node2D = null
var active: bool = false

func get_velocity(from_position: Vector2) -> Vector2:
	if not active or target == null:
		return Vector2.ZERO
	var direction := (target.global_position - from_position).normalized()
	return direction * speed

func start_chasing(new_target: Node2D) -> void:
	target = new_target
	active = true

func stop_chasing() -> void:
	active = false
