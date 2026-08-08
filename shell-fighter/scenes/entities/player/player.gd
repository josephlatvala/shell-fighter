extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Area2D = $Hurtbox

@export var speed: int = 150
@export var knockback_strength: float = 700.0
@export var knockback_friction: float = 900.0  # how fast the knockback velocity decays

var screenSize: Vector2
var knockback_velocity: Vector2 = Vector2.ZERO
var canDash: bool = true

func _ready() -> void:
	screenSize = get_viewport_rect().size
	position = screenSize / 2
	health_component.died.connect(_on_died)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)

# Deals with player damage
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if health_component.is_invincible:
		return
	if body.is_in_group("enemy") and "contact_damage" in body:
		print("Ouchie")
		health_component.take_damage(body.contact_damage)
		_apply_knockback(body.global_position)
		hurtbox.set_deferred("monitoring", false)
		await get_tree().create_timer(health_component.invincibility_time).timeout
		hurtbox.monitoring = true

func _apply_knockback(from_position: Vector2) -> void:
	var direction := (global_position - from_position).normalized()
	knockback_velocity = direction * knockback_strength

func _on_died() -> void:
	# TODO: hook up to a game over
	queue_free()

func get_input():
	var directionalInput = Input.get_vector("leftMovement", "rightMovement", "upMovement", "downMovement")
	velocity = directionalInput.normalized() * speed

func _physics_process(delta):
	get_input()
	velocity += knockback_velocity
	move_and_slide()
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	if Input.is_action_just_pressed("dash") and $InDashTimer.time_left == 0 and !velocity.is_zero_approx() and canDash:
		dash()
	
func dash():
	canDash = false
	speed = speed * 4
	$InDashTimer.start()
	$DashCooldownTimer.start()

func _on_dash_cooldown_timer_timeout():
	canDash = true


func _on_in_dash_timer_timeout():
	speed = speed / 4
