extends Area2D
class_name DetectionZone

signal target_spotted(target: Node2D)
signal target_lost(target: Node2D)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_spotted.emit(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_lost.emit(body)
