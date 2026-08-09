extends ReferenceRect

const ENEMY = preload("res://scenes/entities/enemy/enemy.tscn")
const HEAVYENEMY = preload("res://scenes/entities/enemy/heavyEnemy.tscn")
const LIGHTENEMY = preload("res://scenes/entities/enemy/lightEnemy.tscn")

const minimum_spawn_delay: float = 3
const maximum_spawn_delay: float = 5
const minimum_spawn_count: int = 1
const maximum_spawn_count: int = 5

@onready var level: Node2D = $".."
@onready var spawning_area: Vector4 = Vector4(position.x, size.x, position.y, size.y)

var time_until_next_spawn = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_until_next_spawn <= 0:
		randomize() #TODO: move this to the start of the game
		var spawn_count = randi_range(minimum_spawn_count, maximum_spawn_count)
		
		for _i in range(spawn_count):
			var enemyType: int = randi_range(0, 2)
			var newEnemy
			
			if enemyType == 0:
				newEnemy = ENEMY.instantiate()
			elif enemyType == 1:
				newEnemy = HEAVYENEMY.instantiate()
			elif enemyType == 2:
				newEnemy = LIGHTENEMY.instantiate()
			
			newEnemy.position = Vector2(
				randi_range(spawning_area.w, spawning_area.x),
				randi_range(spawning_area.y, spawning_area.z),
			)
			
			level.add_child(newEnemy)
		
		time_until_next_spawn = randf_range(minimum_spawn_delay, maximum_spawn_delay)

	else:
		time_until_next_spawn -= delta
