extends ReferenceRect

@export var minimum_spawn_delay: float = 3
@export var maximum_spawn_delay: float = 6
@export var minimum_spawn_count: int = 2
@export var maximum_spawn_count: int = 6
@export var enemy_table: Array[Resource] = [preload("res://scenes/entities/enemy/enemy.tscn")]

@onready var level: Node2D = $"../.."
@onready var spawning_area: Vector4 = Vector4(position.x, size.x, position.y, size.y)

var time_until_next_spawn = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if enemy_table.size() <= 0:
		# Nothing to spawn
		return
	
	if time_until_next_spawn <= 0:
		randomize() #TODO: move this to the start of the game
		var spawn_count = randi_range(minimum_spawn_count, maximum_spawn_count)
		
		for _i in range(spawn_count):
			var enemyType: int = randi_range(0, 2)
			var NEW_ENEMY_TYPE = enemy_table.pick_random()
			var newEnemy = NEW_ENEMY_TYPE.instantiate()
			
			newEnemy.position = Vector2(
				randi_range(spawning_area.w, spawning_area.x),
				randi_range(spawning_area.y, spawning_area.z),
			)
			
			level.add_child(newEnemy)
		
		time_until_next_spawn = randf_range(minimum_spawn_delay, maximum_spawn_delay)

	else:
		time_until_next_spawn -= delta
