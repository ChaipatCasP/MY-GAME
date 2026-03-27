# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does touch-based tile farming feel satisfying on mobile?
# Date: 2026-03-27

extends Node2D

# Tile state -- simple enum-like constants
const STATE_EMPTY:   int = 0
const STATE_GROWING: int = 1    # days_to_grow remaining > 0
const STATE_READY:   int = 2    # harvestable

# Hardcoded crop: grows in 3 days (adjustable for testing)
const GROW_TIME: int = 3

var tile_size: int = 56
var state: int = STATE_EMPTY
var days_remaining: int = 0
var watered: bool = false  # Visual indicator — resets each day

signal harvested  # Emitted when player taps a READY tile


func setup(size: int) -> void:
	tile_size = size
	_redraw()


func advance_day() -> void:
	if state == STATE_GROWING:
		days_remaining -= 1
		if days_remaining <= 0:
			state = STATE_READY
	watered = false
	_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		var pressed: bool = (event is InputEventScreenTouch and event.pressed) \
			or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
		if pressed and _is_touch_inside(event.position):
			_on_tapped()


func _on_tapped() -> void:
	match state:
		STATE_EMPTY:
			state = STATE_GROWING
			days_remaining = GROW_TIME
			_animate_plant()
		STATE_GROWING:
			watered = true
			_animate_water()
		STATE_READY:
			state = STATE_EMPTY
			emit_signal("harvested")
			_animate_harvest()
	_redraw()


func _is_touch_inside(screen_pos: Vector2) -> bool:
	var local: Vector2 = to_local(screen_pos)
	return local.x >= 0 and local.x <= tile_size \
		and local.y >= 0 and local.y <= tile_size


func _redraw() -> void:
	queue_redraw()


# ---- Drawing ----

func _draw() -> void:
	var ts: float = float(tile_size)
	var center := Vector2(ts * 0.5, ts * 0.5)
	match state:
		STATE_EMPTY:   _draw_soil(ts, center)
		STATE_GROWING: _draw_sprout(ts, center)
		STATE_READY:   _draw_bloom(ts, center)


func _draw_soil(ts: float, _center: Vector2) -> void:
	# Rich two-tone soil
	draw_rect(Rect2(0, 0, ts, ts), Color(0.40, 0.24, 0.11))
	draw_rect(Rect2(1, 1, ts - 2, ts * 0.45), Color(0.50, 0.31, 0.15))
	# Texture marks (cross shapes suggest tilled earth)
	var marks: Array[Vector2] = [
		Vector2(ts * 0.22, ts * 0.35), Vector2(ts * 0.50, ts * 0.28),
		Vector2(ts * 0.78, ts * 0.35), Vector2(ts * 0.33, ts * 0.65),
		Vector2(ts * 0.67, ts * 0.62),
	]
	for m in marks:
		_draw_cross(m, Color(0.28, 0.15, 0.06), 3.5)
	# Bottom shadow strip
	draw_rect(Rect2(0, ts * 0.78, ts, ts * 0.22), Color(0.30, 0.17, 0.07))
	# Border
	draw_rect(Rect2(0, 0, ts, ts), Color(0.20, 0.10, 0.04), false, 1.5)


func _draw_sprout(ts: float, center: Vector2) -> void:
	# Background — bright top, richer bottom
	draw_rect(Rect2(0, 0, ts, ts), Color(0.17, 0.48, 0.16))
	draw_rect(Rect2(1, 1, ts - 2, ts * 0.5), Color(0.24, 0.62, 0.21))

	# Watered: blue shimmer + droplets
	if watered:
		draw_rect(Rect2(0, 0, ts, ts), Color(0.30, 0.60, 1.00, 0.18))
		draw_circle(Vector2(ts * 0.20, ts * 0.22), 3.0, Color(0.50, 0.75, 1.00, 0.90))
		draw_circle(Vector2(ts * 0.80, ts * 0.26), 2.5, Color(0.50, 0.75, 1.00, 0.90))

	# Stem
	draw_line(
		Vector2(center.x, ts - 7.0),
		Vector2(center.x, center.y - 6.0),
		Color(0.12, 0.40, 0.09), 3.0
	)
	# Left leaf
	draw_polygon(PackedVector2Array([
		Vector2(center.x,        center.y + 2),
		Vector2(center.x - 13,   center.y - 5),
		Vector2(center.x - 2,    center.y + 11),
	]), PackedColorArray([
		Color(0.13, 0.50, 0.10),
		Color(0.13, 0.50, 0.10),
		Color(0.13, 0.50, 0.10),
	]))
	# Right leaf
	draw_polygon(PackedVector2Array([
		Vector2(center.x,        center.y + 2),
		Vector2(center.x + 13,   center.y - 5),
		Vector2(center.x + 2,    center.y + 11),
	]), PackedColorArray([
		Color(0.20, 0.62, 0.14),
		Color(0.20, 0.62, 0.14),
		Color(0.20, 0.62, 0.14),
	]))
	# Bud tip
	draw_circle(Vector2(center.x, center.y - 9), 4.5, Color(0.26, 0.72, 0.19))
	draw_circle(Vector2(center.x, center.y - 9), 2.5, Color(0.55, 0.92, 0.40))

	# Days badge — bottom-right corner
	draw_rect(Rect2(ts - 19, ts - 19, 17, 16), Color(0.08, 0.08, 0.08, 0.65))
	draw_string(
		ThemeDB.fallback_font,
		Vector2(ts - 15, ts - 6),
		str(days_remaining),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
		Color(1.0, 1.0, 0.55)
	)
	# Border
	draw_rect(Rect2(0, 0, ts, ts), Color(0.09, 0.32, 0.07), false, 1.5)


func _draw_bloom(ts: float, center: Vector2) -> void:
	# Warm golden background
	draw_rect(Rect2(0, 0, ts, ts), Color(0.78, 0.55, 0.03))
	draw_rect(Rect2(1, 1, ts - 2, ts * 0.52), Color(0.96, 0.82, 0.18))

	# Sunburst petals
	var petal_r: float = ts * 0.33
	for i in 8:
		var angle: float = (TAU / 8.0) * i
		var tip: Vector2 = center + Vector2(cos(angle) * petal_r, sin(angle) * petal_r)
		draw_line(center, tip, Color(1.00, 0.90, 0.25, 0.90), 3.5)

	# Flower center
	draw_circle(center, ts * 0.19, Color(1.00, 0.70, 0.08))
	draw_circle(center, ts * 0.12, Color(1.00, 0.94, 0.52))

	# Corner sparkles
	var corners: Array[Vector2] = [
		Vector2(ts * 0.15, ts * 0.14), Vector2(ts * 0.85, ts * 0.14),
		Vector2(ts * 0.15, ts * 0.86), Vector2(ts * 0.85, ts * 0.86),
	]
	for c in corners:
		draw_circle(c, 2.5, Color(1.0, 1.0, 0.75, 0.88))

	# Border
	draw_rect(Rect2(0, 0, ts, ts), Color(0.52, 0.32, 0.02), false, 1.5)


func _draw_cross(pos: Vector2, color: Color, size: float) -> void:
	draw_line(Vector2(pos.x - size, pos.y), Vector2(pos.x + size, pos.y), color, 1.5)
	draw_line(Vector2(pos.x, pos.y - size), Vector2(pos.x, pos.y + size), color, 1.5)


# ---- Animations ----

func _animate_plant() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.82, 0.82), 0.07)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.10)
	tween.tween_property(self, "scale", Vector2(1.00, 1.00), 0.06)


func _animate_water() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.65, 0.85, 1.30), 0.10)
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func _animate_harvest() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.09)
	tween.tween_property(self, "modulate", Color(1.5, 1.5, 0.5, 0.5), 0.06)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.13)
	tween.tween_callback(func() -> void:
		scale = Vector2.ONE
		modulate = Color.WHITE
		_redraw()
	)
