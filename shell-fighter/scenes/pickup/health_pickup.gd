extends Area2D

@export var heal_amount: int = 20
# If true, the pickup stays in the world (isn't consumed) when the player is
# already at full HP.
@export var only_consume_when_damaged: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not body.has_node("HealthComponent"):
		return

	var health_component: HealthComponent = body.get_node("HealthComponent")

	if only_consume_when_damaged and health_component.current_health >= health_component.max_health:
		return

	health_component.heal(heal_amount)
	queue_free()
