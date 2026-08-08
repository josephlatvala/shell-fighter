extends CharacterBody2D

@export var contact_damage: int = 10
@export var score_value: int= 10

@onready var chase_component: ChaseComponent = $ChaseComponent
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		chase_component.start_chasing(player)
	health_component.died.connect(_on_died)

func _physics_process(_delta: float) -> void:
	velocity = chase_component.get_velocity(global_position)
	move_and_slide()

func _on_died() -> void:
	Score.add_score(score_value)
	queue_free()
