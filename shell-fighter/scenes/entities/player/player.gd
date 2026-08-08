extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	health_component.died.connect(_on_died)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)

# Deals with player damage
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and "contact_damage" in body:
		health_component.take_damage(body.contact_damage)

func _on_died() -> void:
	# TODO: hook up to a game over
	queue_free()
