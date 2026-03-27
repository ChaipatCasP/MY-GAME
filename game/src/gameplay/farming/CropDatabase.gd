extends Node
## CropDatabase — singleton-style helper that reads crops.json at startup
## and exposes fast lookups by crop_id.
## Not an autoload — instantiated by the Boot scene.

const DATA_PATH: String = "res://assets/data/crops.json"

var _crops: Dictionary = {}  # crop_id -> crop data dict


func _ready() -> void:
	_load()


func _load() -> void:
	if not ResourceLoader.exists(DATA_PATH):
		push_error("CropDatabase: crops.json not found at %s" % DATA_PATH)
		return
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("CropDatabase: cannot open crops.json")
		return
	var result: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if result == null or not result is Array:
		push_error("CropDatabase: crops.json root must be a JSON array")
		return
	for entry: Variant in result as Array:
		var crop: Dictionary = entry as Dictionary
		var id: String = crop.get("id", "") as String
		if id != "":
			_crops[id] = crop


## Returns a copy of the crop definition, or empty dict if not found.
func get_crop(crop_id: String) -> Dictionary:
	if not _crops.has(crop_id):
		push_warning("CropDatabase: unknown crop_id '%s'" % crop_id)
		return {}
	return (_crops[crop_id] as Dictionary).duplicate()


func all_ids() -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in _crops.keys():
		ids.append(key as String)
	return ids
