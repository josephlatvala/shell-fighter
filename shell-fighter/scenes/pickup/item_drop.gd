extends Node

# create new nodes randomly selected from children

@export var min_drop: int = 1
@export var max_drop: int = 1
@export var range: Vector4 = Vector4(0,0,0,0)

@onready var parent = $".."
@onready var health_component = $"../HealthComponent"

func _ready():
	health_component.connect("died", _on_died)

func _on_died() -> void:
	print("[item_drop] dropping item %s from %s" % [
		"ammo",
		parent.name,
	])
	var children = get_children()
	
	
	if children.size() <= 0:
		push_error("no possible drops for item_drop under %s" % [parent.name])
		return
		
	for _i in range(randi_range(min_drop, max_drop)):
		var item_type = children.pick_random() as Node2D
		var new_item = item_type.duplicate()
		var position_offset = Vector2(
			randi_range(range.w, range.x),
			randi_range(range.y, range.z),
		)
		new_item.position = position_offset + parent.position
		parent.add_sibling.call_deferred(new_item)


func _on_health_component_died() -> void:
	pass # Replace with function body.
