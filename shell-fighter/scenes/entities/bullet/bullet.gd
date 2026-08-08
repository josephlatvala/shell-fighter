extends Node2D

const EXPLOSION_EFFECT = preload("res://scenes/entities/bullet/explosion_effect.tscn")

var bullet_data: BulletData
var damage: int = 0
var timeToLive: float = 0

@onready var rigid_body_2d: RigidBody2D = $RigidBody2D
@onready var area_2d: Area2D = $RigidBody2D/Area2D
@onready var sprite_2d: Sprite2D = $RigidBody2D/Sprite2D
@onready var timeLived: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered) # Connect area 2d object with function

# Configures this bullet instance from a BulletData resource.
func setup(data: BulletData) -> void:
	bullet_data = data
	damage = data.damage
	timeToLive = data.time_to_live

	if data.texture:
		sprite_2d.texture = data.texture
	sprite_2d.scale = Vector2(data.sprite_scale, data.sprite_scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timeLived += delta

	if bullet_data and bullet_data.is_grenade:
		if timeLived >= bullet_data.fuse_time:
			_explode()
		return

	if timeLived >= timeToLive:
		queue_free()

# Called when an Area node intersects with the bullet.
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemy"):
		return

	if bullet_data and bullet_data.is_grenade:
		_explode()
	else:
		var health_component := body.get_node_or_null("HealthComponent") as HealthComponent
		if health_component:
			var hp_before := health_component.current_health
			health_component.take_damage(damage)
			print("[%s] hit %s: %d dmg, %d HP -> %d HP" % [
				bullet_data.resource_path.get_file() if bullet_data else "unknown_bullet",
				body.name, damage, hp_before, health_component.current_health
			])
		queue_free()

# Deals AoE damage to every enemy within explosion_radius, then frees the bullet.
func _explode() -> void:
	# Use the RigidBody2D's position, not the root Node2D's, the root never
	# moves (physics only updates the RigidBody2D child's transform), so
	# self.global_position would still be sitting back at the spawn point.
	var explosion_position: Vector2 = rigid_body_2d.global_position

	_spawn_explosion_visual(explosion_position)

	var hit_count := 0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var dist := explosion_position.distance_to(enemy.global_position)
		if dist <= bullet_data.explosion_radius:
			var health_component := enemy.get_node_or_null("HealthComponent") as HealthComponent
			if health_component:
				var hp_before := health_component.current_health
				health_component.take_damage(damage)
				print("[%s] hit %s: %d dmg, %d HP -> %d HP" % [
					bullet_data.resource_path.get_file(),
					enemy.name, damage, hp_before, health_component.current_health
				])
				hit_count += 1

	print("Grenade exploded: hit %d enem%s within radius %.1f" % [
		hit_count,
		"y" if hit_count == 1 else "ies",
		bullet_data.explosion_radius
	])

	queue_free()

func _spawn_explosion_visual(explosion_position: Vector2) -> void:
	var effect := EXPLOSION_EFFECT.instantiate()
	effect.global_position = explosion_position
	effect.radius = bullet_data.explosion_radius
	get_tree().current_scene.add_child(effect)
