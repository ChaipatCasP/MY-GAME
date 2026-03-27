extends Node2D
## FarmScene — root scene that wires FarmGrid, FarmHUD, and SpiritQuestSystem.

@onready var farm_grid: Node2D = $FarmGrid
@onready var farm_hud: CanvasLayer = $FarmHUD


func _ready() -> void:
	# Restore grid state if a save was loaded.
	if not GameState.farm_tiles.is_empty():
		farm_grid.deserialize()

	DayManager.day_advanced.connect(_on_day_advanced)
	SpiritQuestSystem.quest_loaded.connect(_on_quest_loaded)

	# Wire Next Day button.
	var btn: Button = farm_hud.get_node("NextDayButton") as Button
	if btn != null:
		btn.pressed.connect(DayManager.request_advance)


func _on_day_advanced(_new_day: int) -> void:
	farm_grid.serialize()


func _on_quest_loaded(_island_id: String) -> void:
	var island: Dictionary = IslandDatabase.get_island(GameState.current_island_id)
	var track: String = island.get("ambient_music", "") as String
	if track != "":
		AudioManager.play_music(track)


func _on_tile_harvested(tile: Node) -> void:
	farm_hud.increment_harvest(tile.crop_yield)
