extends Area2D

@export var ammo_amount: int = 5

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_node("AmmoComponent"):
		var ammo_component: AmmoComponent = body.get_node("AmmoComponent")
		ammo_component.add_ammo(ammo_amount)
		queue_free()
