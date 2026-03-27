extends Node
## IslandDatabase — reads islands.json at startup and exposes island lookups.
## Not an autoload; instantiated and added to Boot scene.

const DATA_PATH: String = "res://assets/data/islands.json"

var _islands: Dictionary = {}  # island_id -> island data dict


func _ready() -> void:
	_load()


func _load() -> void:
	if not ResourceLoader.exists(DATA_PATH):
		push_error("IslandDatabase: islands.json not found at %s" % DATA_PATH)
		return
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("IslandDatabase: cannot open islands.json")
		return
	var result: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if result == null or not result is Array:
		push_error("IslandDatabase: islands.json root must be a JSON array")
		return
	for entry: Variant in result as Array:
		var island: Dictionary = entry as Dictionary
		var id: String = island.get("island_id", "") as String
		if id != "":
			_islands[id] = island


func get_island(island_id: String) -> Dictionary:
	if not _islands.has(island_id):
		push_warning("IslandDatabase: unknown island_id '%s'" % island_id)
		return {}
	return (_islands[island_id] as Dictionary).duplicate(true)


func all_ids() -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in _islands.keys():
		ids.append(key as String)
	return ids
