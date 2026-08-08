extends CanvasLayer

@onready var score_label: Label = $Root/ScoreLabel
@onready var health_label: Label = $Root/HealthLabel

func _ready() -> void:
	Score.score_changed.connect(_on_score_changed)
	_on_score_changed(Score.score)

	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_node("HealthComponent"):
		var health_component: HealthComponent = player.get_node("HealthComponent")
		health_component.health_changed.connect(_on_health_changed)
		_on_health_changed(health_component.current_health, health_component.max_health)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "%d" % new_score

func _on_health_changed(current: int, max_health: int) -> void:
	health_label.text = "%d" % current
