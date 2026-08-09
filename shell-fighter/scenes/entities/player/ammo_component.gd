extends Node
class_name AmmoComponent

signal ammo_changed(bullet_data: BulletData, current: int, max: int)
signal out_of_ammo(bullet_data: BulletData)

# Each bullet type gets its own pool, sized by that BulletData's max_ammo.
@export var tracked_bullet_types: Array[BulletData] = []

var _ammo: Dictionary = {} # BulletData -> current ammo (int)

func _ready() -> void:
	for data in tracked_bullet_types:
		if data:
			_register(data)

func _register(data: BulletData) -> void:
	if not _ammo.has(data):
		_ammo[data] = data.max_ammo

func try_use_ammo(bullet_data: BulletData, amount: int = -1) -> bool:
	if not bullet_data:
		return false
	_register(bullet_data)

	var cost := amount if amount >= 0 else bullet_data.ammo_cost
	var current: int = _ammo[bullet_data]

	if current < cost:
		return false

	current -= cost
	_ammo[bullet_data] = current
	print("%s ammo left: %d" % [bullet_data.resource_path.get_file(), current])
	ammo_changed.emit(bullet_data, current, bullet_data.max_ammo)
	if current == 0:
		out_of_ammo.emit(bullet_data)
	return true

func add_ammo(bullet_data: BulletData, amount: int) -> void:
	print("[ammo] Trying to add ammo")
	if not bullet_data:
		return
	_register(bullet_data)

	var current: int = min(_ammo[bullet_data] + amount, bullet_data.max_ammo)
	_ammo[bullet_data] = current
	ammo_changed.emit(bullet_data, current, bullet_data.max_ammo)
	print("[ammo] adding ammo, now at %s" % [_ammo[bullet_data]])

func is_empty(bullet_data: BulletData) -> bool:
	if not bullet_data:
		return true
	_register(bullet_data)
	return _ammo[bullet_data] <= 0

func get_current_ammo(bullet_data: BulletData) -> int:
	if not bullet_data:
		return 0
	_register(bullet_data)
	return _ammo[bullet_data]
