extends Node
class_name HealthComponent

signal health_changed(current: int, max: int)
signal damaged(amount: int)
signal healed(amount: int)
signal died

@onready var sfx_enemy_hurt: AudioStreamPlayer = $sfxEnemyHurt

@export var max_health: int = 100
@export var invincibility_time: float = 0.5  # seconds of i-frames after taking damage, 0 = off

var current_health: int
var is_invincible: bool = false

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func take_damage(amount: int) -> void:
	if(sfx_enemy_hurt != null):
		sfx_enemy_hurt.play()
	if is_invincible or current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		print("firing death event")
		died.emit()
	elif invincibility_time > 0.0:
		_start_invincibility()

func heal(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = min(current_health + amount, max_health)
	healed.emit(amount)
	health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0

func _start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false
