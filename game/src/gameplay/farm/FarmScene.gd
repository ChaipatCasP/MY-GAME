extends Node2D
## FarmScene — root scene that wires FarmGrid ↔ FarmHUD ↔ CropDatabase.

@onready var farm_grid: Node2D = $FarmGrid
@onready var farm_hud: CanvasLayer = $FarmHUD


func _ready() -> void:
	# Restore grid state if a save was loaded.
	if not GameState.farm_tiles.is_empty():
		farm_grid.deserialize()

	# Wire harvest events from grid to HUD.
	farm_grid.connect("child_entered_tree", _on_grid_child_added)
	DayManager.day_advanced.connect(_on_day_advanced)

	# Wire Next Day button.
	var btn: Button = farm_hud.get_node("NextDayButton") as Button
	if btn != null:
		btn.pressed.connect(DayManager.request_advance)


func _on_day_advanced(new_day: int) -> void:
	farm_grid.serialize()


func _on_grid_child_added(node: Node) -> void:
	# Connect harvest signal from newly added CropTile nodes.
	if node.has_signal("harvested"):
		node.connect("harvested", _on_tile_harvested)


func _on_tile_harvested(tile: Node) -> void:
	farm_hud.increment_harvest(tile.crop_yield)
