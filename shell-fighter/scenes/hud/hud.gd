extends CanvasLayer

@onready var score_label: Label = $Root/ScoreLabel
@onready var health_label: Label = $Root/HealthLabel
@onready var weapon_icon: TextureRect = $Root/WeaponIcon

@onready var normal_ammo_label: Label = $Root/NormalAmmoLabel
@onready var scatter_ammo_label: Label = $Root/ScatterAmmoLabel
@onready var grenade_ammo_label: Label = $Root/GrenadeAmmoLabel

# Assign these in the Inspector to the SAME .tres files used on
# shootingComponent's normal_bullet_data / scatter_bullet_data / grenade_bullet_data
@export var normal_icon: Texture2D
@export var scatter_icon: Texture2D
@export var grenade_icon: Texture2D

var shooting: Node2D # cached shootingComponent ref, used to identify bullet types by resource

func _ready() -> void:
	Score.score_changed.connect(_on_score_changed)
	_on_score_changed(Score.score)

	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_node("HealthComponent"):
		var health_component: HealthComponent = player.get_node("HealthComponent")
		health_component.health_changed.connect(_on_health_changed)
		_on_health_changed(health_component.current_health, health_component.max_health)

	if player and player.has_node("shootingComponent"):
		shooting = player.get_node("shootingComponent")
		shooting.bullet_type_changed.connect(_on_bullet_type_changed)
		# shootingComponent's own _ready() may not have run yet, so
		# current_bullet_data could still be null here - only prime if
		# it's already set; otherwise the signal will catch us up shortly.
		if shooting.current_bullet_data:
			_on_bullet_type_changed(shooting.current_bullet_data)

	if player and player.has_node("AmmoComponent"):
		var ammo_component: AmmoComponent = player.get_node("AmmoComponent")
		ammo_component.ammo_changed.connect(_on_ammo_changed)
		# Prime all three labels with current ammo, once shooting is available
		# to identify which .tres is which type.
		if shooting:
			if shooting.normal_bullet_data:
				_on_ammo_changed(shooting.normal_bullet_data, ammo_component.get_current_ammo(shooting.normal_bullet_data), shooting.normal_bullet_data.max_ammo)
			if shooting.scatter_bullet_data:
				_on_ammo_changed(shooting.scatter_bullet_data, ammo_component.get_current_ammo(shooting.scatter_bullet_data), shooting.scatter_bullet_data.max_ammo)
			if shooting.grenade_bullet_data:
				_on_ammo_changed(shooting.grenade_bullet_data, ammo_component.get_current_ammo(shooting.grenade_bullet_data), shooting.grenade_bullet_data.max_ammo)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "%d" % new_score

func _on_health_changed(current: int, _max: int) -> void:
	health_label.text = "%d" % current

func _on_bullet_type_changed(bullet_data: BulletData) -> void:
	if not bullet_data:
		return
	if bullet_data.is_grenade:
		weapon_icon.texture = grenade_icon
	elif bullet_data.shot_count > 1 and bullet_data.spread > 0.05:
		weapon_icon.texture = scatter_icon
	else:
		weapon_icon.texture = normal_icon

func _on_ammo_changed(bullet_data: BulletData, current: int, _max: int) -> void:
	if not bullet_data or not shooting:
		return
	if bullet_data == shooting.normal_bullet_data:
		normal_ammo_label.text = "%d" % current
	elif bullet_data == shooting.scatter_bullet_data:
		scatter_ammo_label.text = "%d" % current
	elif bullet_data == shooting.grenade_bullet_data:
		grenade_ammo_label.text = "%d" % current
