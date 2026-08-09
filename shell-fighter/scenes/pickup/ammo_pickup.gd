extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var bullet_data: BulletData
@export var ammo_amount: int = 5

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if bullet_data:
		var icon = bullet_data.pickup_texture if bullet_data.pickup_texture else bullet_data.texture
		if icon:
			sprite_2d.texture = icon
		sprite_2d.scale = Vector2.ONE * bullet_data.pickup_scale
		sprite_2d.modulate = Color.WHITE

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not body.has_node("AmmoComponent"):
		return

	var ammo_component: AmmoComponent = body.get_node("AmmoComponent")

	if bullet_data:
		ammo_component.add_ammo(bullet_data, ammo_amount)
	else:
		for data in ammo_component.tracked_bullet_types:
			ammo_component.add_ammo(data, ammo_amount)

	queue_free()
