# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does touch-based tile farming feel satisfying on mobile?
# Date: 2026-03-27

extends Node2D

# Hardcoded layout — prototype only
const GRID_COLS: int = 6
const GRID_ROWS: int = 8
const TILE_SIZE: int = 56  # px — sized for mobile touch targets (min 44pt)
const TILE_GAP: int = 4

@onready var grid: Node2D = $FarmGrid
@onready var day_label: Label = $UI/DayLabel
@onready var harvest_label: Label = $UI/HarvestLabel
@onready var next_day_btn: Button = $UI/NextDayButton

var current_day: int = 1
var total_harvested: int = 0

func _ready() -> void:
	grid.setup(GRID_COLS, GRID_ROWS, TILE_SIZE, TILE_GAP)
	_update_ui()


func _on_next_day_pressed() -> void:
	current_day += 1
	grid.advance_day()
	_update_ui()
	_flash_day_label()


func on_crop_harvested() -> void:
	total_harvested += 1
	_update_ui()


func _update_ui() -> void:
	day_label.text = "Day %d" % current_day
	harvest_label.text = "Harvested: %d" % total_harvested


func _flash_day_label() -> void:
	# Quick visual feedback that the day advanced
	var tween: Tween = create_tween()
	tween.tween_property(day_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(day_label, "scale", Vector2(1.0, 1.0), 0.15)
