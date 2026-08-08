extends Resource
class_name BulletData

# Visual
@export var texture: Texture2D
@export var sprite_scale: float = 0.05

# Combat
@export var damage: int = 10
@export var speed: float = 100.0
@export var time_to_live: float = 0.3

# Spread pattern
@export var shot_count: int = 5
@export var spread: float = PI * 0.01

# Grenade-specific (ignored when is_grenade is false)
@export var is_grenade: bool = false
@export var fuse_time: float = 1.0
@export var explosion_radius: float = 40.0

# Ammo (this bullet type has its own independent pool)
@export var max_ammo: int = 20
@export var ammo_cost: int = 1
