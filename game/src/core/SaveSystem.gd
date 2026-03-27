extends Node
## SaveSystem — autoload that handles all save and load operations.
## Saves synchronously to UserData (mobile safe).
## Save format version is stored to handle future migrations.

const SAVE_PATH: String = "user://drifting_seasons.save"
const SAVE_VERSION: int = 1


## Called automatically on day_advanced signal.
## Also callable manually (e.g., before app close).
func save() -> void:
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"current_day": GameState.current_day,
		"current_island_id": GameState.current_island_id,
		"inventory": GameState.inventory.duplicate(),
		"known_seeds": GameState.known_seeds.duplicate(),
		"completed_quests": GameState.completed_quests.duplicate(),
		"lore_fragments": GameState.lore_fragments.duplicate(),
		"farm_tiles": GameState.farm_tiles.duplicate(true),
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: cannot open save file for writing")
		return
	file.store_string(JSON.stringify(data))
	file.close()


func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveSystem: cannot open save file for reading")
		return false
	var text: String = file.get_as_text()
	file.close()

	var result: Variant = JSON.parse_string(text)
	if result == null or not result is Dictionary:
		push_error("SaveSystem: save file is corrupt")
		return false

	var data: Dictionary = result as Dictionary
	var version: int = data.get("version", 0) as int
	if version < SAVE_VERSION:
		_migrate(data, version)

	GameState.current_day = data.get("current_day", 1) as int
	GameState.current_island_id = data.get("current_island_id", "island_spring") as String
	GameState.inventory = data.get("inventory", {}) as Dictionary
	GameState.known_seeds = data.get("known_seeds", ["clover"]) as Array[String]
	GameState.completed_quests = data.get("completed_quests", []) as Array[String]
	GameState.lore_fragments = data.get("lore_fragments", []) as Array[int]
	GameState.farm_tiles = data.get("farm_tiles", {}) as Dictionary
	return true


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


func _migrate(_data: Dictionary, _from_version: int) -> void:
	# Future: handle save format migrations here.
	push_warning("SaveSystem: migrating save from version %d" % _from_version)


func _ready() -> void:
	DayManager.day_advanced.connect(_on_day_advanced)


func _on_day_advanced(_new_day: int) -> void:
	save()
