extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

# Which pool this pickup refills.
@export var bullet_data: BulletData
@export var ammo_amount: int = 5

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if bullet_data.texture:
		sprite_2d.texture = bullet_data.texture

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not body.has_node("AmmoComponent"):
		return

	var ammo_component: AmmoComponent = body.get_node("AmmoComponent")

	print("[ammo_pickup] trying to give ammo")
	if bullet_data:
		ammo_component.add_ammo(bullet_data, ammo_amount)
	else:
		for data in ammo_component.tracked_bullet_types:
			ammo_component.add_ammo(data, ammo_amount)

	queue_free()
