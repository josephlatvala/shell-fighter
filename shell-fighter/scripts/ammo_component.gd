extends Node
class_name AmmoComponent

signal ammo_changed(current: int, max: int)
signal out_of_ammo

@export var max_ammo: int = 20

var current_ammo: int = max_ammo

func try_use_ammo(amount: int = 1) -> bool:
	if current_ammo < amount:
		return false

	current_ammo -= amount
	ammo_changed.emit(current_ammo, max_ammo)
	if current_ammo == 0:
		out_of_ammo.emit()
	return true

func add_ammo(amount: int) -> void:
	current_ammo = min(current_ammo + amount, max_ammo)
	ammo_changed.emit(current_ammo, max_ammo)

func is_empty() -> bool:
	return current_ammo <= 0
