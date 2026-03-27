# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does touch-based tile farming feel satisfying on mobile?
# Date: 2026-03-27

extends Node2D

# Tile state -- simple enum-like constants
const STATE_EMPTY: int = 0
const STATE_GROWING: int = 1    # days_to_grow remaining > 0
const STATE_READY: int = 2      # harvestable

# Placeholder colors per state (no sprites needed for this prototype)
const COLOR_EMPTY:    Color = Color(0.45, 0.30, 0.18)  # brown soil
const COLOR_GROWING:  Color = Color(0.25, 0.65, 0.25)  # green sprout
const COLOR_READY:    Color = Color(0.95, 0.85, 0.10)  # golden harvest

# Hardcoded crop: grows in 3 days (adjustable for testing)
const GROW_TIME: int = 3

var tile_size: int = 56
var state: int = STATE_EMPTY
var days_remaining: int = 0

signal harvested  # Emitted when player taps a READY tile


func setup(size: int) -> void:
	tile_size = size
	_redraw()


func advance_day() -> void:
	if state == STATE_GROWING:
		days_remaining -= 1
		if days_remaining <= 0:
			state = STATE_READY
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
			# Plant a seed
			state = STATE_GROWING
			days_remaining = GROW_TIME
			_animate_plant()
		STATE_GROWING:
			# Water — visual only in prototype (could speed grow slightly)
			_animate_water()
		STATE_READY:
			# Harvest
			state = STATE_EMPTY
			emit_signal("harvested")
			_animate_harvest()
	_redraw()


func _is_touch_inside(screen_pos: Vector2) -> bool:
	var local: Vector2 = to_local(screen_pos)
	var half: float = tile_size / 2.0
	return local.x >= 0 and local.x <= tile_size \
		and local.y >= 0 and local.y <= tile_size


func _redraw() -> void:
	queue_redraw()


func _draw() -> void:
	var color: Color
	match state:
		STATE_EMPTY:   color = COLOR_EMPTY
		STATE_GROWING: color = COLOR_GROWING
		STATE_READY:   color = COLOR_READY
	
	draw_rect(Rect2(0, 0, tile_size, tile_size), color)
	draw_rect(Rect2(0, 0, tile_size, tile_size), Color.BLACK, false, 1.5)
	
	# Show days remaining when growing
	if state == STATE_GROWING:
		draw_string(
			ThemeDB.fallback_font,
			Vector2(tile_size / 2.0 - 6, tile_size / 2.0 + 6),
			str(days_remaining),
			HORIZONTAL_ALIGNMENT_CENTER, -1, 14,
			Color.WHITE
		)


# ---- Animations (prototype-grade tweens) ----

func _animate_plant() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12)


func _animate_water() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.6, 0.8, 1.2), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)


func _animate_harvest() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.15)
	tween.tween_callback(func() -> void:
		scale = Vector2.ONE
		_redraw()
	)
