extends CharacterBody2D

@onready var chase_component: ChaseComponent = $ChaseComponent

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		chase_component.start_chasing(player)

func _physics_process(_delta: float) -> void:
	velocity = chase_component.get_velocity(global_position)
	move_and_slide()
