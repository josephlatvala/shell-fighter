extends Node2D

# Debug/placeholder explosion visual: draws an expanding, fading ring so to
# see where the blast radius actually landed. Swap this out for real
# particles/animation later, just here to make hits visible.
var radius: float = 40.0
var duration: float = 0.25

var _life: float = 0.0

func _process(delta: float) -> void:
	_life += delta
	queue_redraw()
	if _life >= duration:
		queue_free()

func _draw() -> void:
	var t: float = _life / duration
	var alpha: float = 1.0 - t
	var current_radius: float = radius * (0.4 + 0.6 * t) # slight expand-out

	draw_circle(Vector2.ZERO, current_radius, Color(1.0, 0.55, 0.1, alpha * 0.35))
	draw_arc(Vector2.ZERO, current_radius, 0, TAU, 32, Color(1.0, 0.3, 0.0, alpha), 2.0)
