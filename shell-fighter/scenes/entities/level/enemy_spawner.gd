extends ReferenceRect

# Difficulty ramp
@export var initial_grace_period: float = 6.0   # no spawns at all before this
@export var ramp_duration: float = 90.0         # time to go from "easy" to "full difficulty"

# Easy (start of ramp)
@export var min_spawn_delay_start: float = 5.0
@export var max_spawn_delay_start: float = 8.0
@export var min_spawn_count_start: int = 1
@export var max_spawn_count_start: int = 2

# Hard (end of ramp / current values become the ceiling)
@export var min_spawn_delay_end: float = 3.0
@export var max_spawn_delay_end: float = 6.0
@export var min_spawn_count_end: int = 2
@export var max_spawn_count_end: int = 6

# Spawn placement
@export var min_distance_from_player: float = 120.0
@export var max_placement_attempts: int = 8  # tries to find a valid spot before giving up

@export var enemy_table: Array[Resource] = [preload("res://scenes/entities/enemy/enemy.tscn")]

@onready var level: Node2D = $"../.."
@onready var spawning_area: Vector4 = Vector4(position.x, size.x, position.y, size.y)

var elapsed_time: float = 0.0
var time_until_next_spawn: float = 0.0
var _rng_initialized := false

func _ready() -> void:
	if not _rng_initialized:
		randomize()
		_rng_initialized = true
	time_until_next_spawn = initial_grace_period

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta

	if enemy_table.size() <= 0:
		# Nothing to spawn
		return

	if time_until_next_spawn <= 0:
		var ramp_t: float = clamp(elapsed_time / ramp_duration, 0.0, 1.0)

		var min_spawn_delay: float = lerp(min_spawn_delay_start, min_spawn_delay_end, ramp_t)
		var max_spawn_delay: float = lerp(max_spawn_delay_start, max_spawn_delay_end, ramp_t)
		var min_spawn_count: int = round(lerp(float(min_spawn_count_start), float(min_spawn_count_end), ramp_t))
		var max_spawn_count: int = round(lerp(float(max_spawn_count_start), float(max_spawn_count_end), ramp_t))

		var spawn_count = randi_range(min_spawn_count, max_spawn_count)

		for _i in range(spawn_count):
			var NEW_ENEMY_TYPE = enemy_table.pick_random()
			var newEnemy = NEW_ENEMY_TYPE.instantiate()

			newEnemy.position = _get_spawn_position()

			level.add_child(newEnemy)

		time_until_next_spawn = randf_range(min_spawn_delay, max_spawn_delay)

	else:
		time_until_next_spawn -= delta

# Ensures enemies don't spawn near the player
func _get_spawn_position() -> Vector2:
	var player: Node2D = get_tree().get_first_node_in_group("player")

	var candidate: Vector2 = Vector2(
		randi_range(spawning_area.w, spawning_area.x),
		randi_range(spawning_area.y, spawning_area.z),
	)

	if player == null:
		return candidate

	var attempts := 0
	while candidate.distance_to(player.global_position) < min_distance_from_player and attempts < max_placement_attempts:
		candidate = Vector2(
			randi_range(spawning_area.w, spawning_area.x),
			randi_range(spawning_area.y, spawning_area.z),
		)
		attempts += 1

	if candidate.distance_to(player.global_position) < min_distance_from_player:
		var away_direction: Vector2 = (candidate - player.global_position)
		if away_direction.length() == 0:
			away_direction = Vector2.RIGHT
		else:
			away_direction = away_direction.normalized()
		candidate = player.global_position + away_direction * min_distance_from_player

	return candidate
