extends Node
class_name FlashOnHit

# Path to the CanvasItem to flash (Sprite2D, Polygon2D, AnimatedSprite2D - any of them work,
# since this just tweens .modulate). Relative to this node.
@export var target_path: NodePath
@export var damage_color: Color = Color(1, 0.35, 0.35) # reddish flash on damage
@export var heal_color: Color = Color(0.4, 1, 0.5)      # greenish flash on heal
@export var flash_duration: float = 0.12

@onready var health_component: HealthComponent = get_parent().get_node("HealthComponent")
@onready var target: CanvasItem = get_node_or_null(target_path)

var _base_modulate: Color
var _tween: Tween

func _ready() -> void:
	if not target:
		push_warning("FlashOnHit: target_path not set or invalid on %s" % get_parent().name)
		return
	_base_modulate = target.modulate

	if health_component:
		health_component.damaged.connect(_on_damaged)
		health_component.healed.connect(_on_healed)
	else:
		push_warning("FlashOnHit: no sibling HealthComponent found on %s" % get_parent().name)

func _on_damaged(_amount: int) -> void:
	_flash(damage_color)

func _on_healed(_amount: int) -> void:
	_flash(heal_color)

func _flash(color: Color) -> void:
	if _tween:
		_tween.kill()
	target.modulate = color
	_tween = create_tween()
	_tween.tween_property(target, "modulate", _base_modulate, flash_duration)
