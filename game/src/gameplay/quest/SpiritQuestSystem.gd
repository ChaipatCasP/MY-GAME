extends Node
## SpiritQuestSystem — autoload that drives the harvest quest for the active island.
## Reads island data from IslandDatabase, checks Inventory, grants rewards.

enum QuestState { IDLE, ACTIVE, COMPLETED }

signal quest_loaded(island_id: String)
signal quest_completed(island_id: String)
signal delivery_failed(missing_crops: Dictionary)  # crop_id -> amount_still_needed

var _state: QuestState = QuestState.IDLE
var _current_quest: Dictionary = {}   # copy of the quest block from islands.json
var _current_island: Dictionary = {}  # full island definition


func _ready() -> void:
	# Load quest for the starting island
	_load_island(GameState.current_island_id)


## Called by Drift / Travel System (or Boot) when the player arrives on a new island.
func load_island(island_id: String) -> void:
	_load_island(island_id)


func _load_island(island_id: String) -> void:
	if island_id == "":
		return
	var island: Dictionary = IslandDatabase.get_island(island_id)
	if island.is_empty():
		push_warning("SpiritQuestSystem: unknown island '%s'" % island_id)
		return

	_current_island = island
	_current_quest = island.get("quest", {}) as Dictionary

	if island_id in GameState.completed_quests:
		_state = QuestState.COMPLETED
	else:
		_state = QuestState.ACTIVE

	quest_loaded.emit(island_id)


## Returns true if all required crops (with substitutions) are available.
func can_deliver() -> bool:
	if _state != QuestState.ACTIVE:
		return false
	var missing: Dictionary = get_missing_crops()
	return missing.is_empty()


## Returns a dict of crop_id -> amount_still_needed for any unmet requirements.
## Returns empty dict if all requirements are met.
func get_missing_crops() -> Dictionary:
	if _current_quest.is_empty():
		return {}

	var effective: Dictionary = _build_effective_counts()
	var missing: Dictionary = {}

	for req: Variant in (_current_quest.get("required_crops", []) as Array):
		var req_dict: Dictionary = req as Dictionary
		var crop_id: String = req_dict.get("crop_id", "") as String
		var needed: int = req_dict.get("amount", 0) as int
		var have: int = effective.get(crop_id, 0) as int
		if have < needed:
			missing[crop_id] = needed - have

	return missing


## The player has confirmed delivery. Deducts crops and grants reward.
## Returns true on success, false if requirements not met.
func attempt_delivery() -> bool:
	if _state != QuestState.ACTIVE:
		return false

	var missing: Dictionary = get_missing_crops()
	if not missing.is_empty():
		delivery_failed.emit(missing)
		return false

	_consume_crops()
	_grant_reward()
	_state = QuestState.COMPLETED
	GameState.completed_quests.append(GameState.current_island_id)
	quest_completed.emit(GameState.current_island_id)
	return true


## Returns the current quest state for UI polling.
func get_state() -> QuestState:
	return _state


## Returns the required crops array from the current quest, or empty array.
func get_required_crops() -> Array:
	return _current_quest.get("required_crops", []) as Array


## Returns the spirit dialogue key appropriate for the current state.
func get_dialogue_key() -> String:
	match _state:
		QuestState.IDLE:
			return "dialogue_intro"
		QuestState.ACTIVE:
			return "dialogue_quest_given"
		QuestState.COMPLETED:
			return "dialogue_complete"
	return "dialogue_intro"


## --- Private helpers ---

func _build_effective_counts() -> Dictionary:
	# Start with raw inventory counts for each required crop.
	var effective: Dictionary = {}
	for req: Variant in (_current_quest.get("required_crops", []) as Array):
		var crop_id: String = (req as Dictionary).get("crop_id", "") as String
		effective[crop_id] = GameState.inventory_count(crop_id)

	# Apply substitution rules defined in the island quest data.
	for sub: Variant in (_current_quest.get("substitutions", []) as Array):
		var sub_dict: Dictionary = sub as Dictionary
		var sub_id: String = sub_dict.get("crop_id", "") as String
		var counts_as: String = sub_dict.get("counts_as", "") as String
		var multiplier: int = sub_dict.get("multiplier", 1) as int
		if counts_as in effective:
			effective[counts_as] = (effective[counts_as] as int) + GameState.inventory_count(sub_id) * multiplier

	return effective


func _consume_crops() -> void:
	# We consume exact required amounts from inventory directly.
	# Substitutes are NOT consumed — only the base required crop IDs.
	# Substitution is a counting aid, not a recipe swap.
	for req: Variant in (_current_quest.get("required_crops", []) as Array):
		var req_dict: Dictionary = req as Dictionary
		var crop_id: String = req_dict.get("crop_id", "") as String
		var amount: int = req_dict.get("amount", 0) as int
		# Consume actual crop first, fill remainder with substitute if available.
		var actual: int = min(GameState.inventory_count(crop_id), amount) as int
		GameState.remove_from_inventory(crop_id, actual)
		var remaining: int = amount - actual
		if remaining > 0:
			# Find a substitute for this crop_id and consume it.
			for sub: Variant in (_current_quest.get("substitutions", []) as Array):
				var sub_dict: Dictionary = sub as Dictionary
				if (sub_dict.get("counts_as", "") as String) == crop_id:
					var sub_id: String = sub_dict.get("crop_id", "") as String
					var multiplier: int = sub_dict.get("multiplier", 1) as int
					var sub_units_needed: int = ceili(float(remaining) / float(multiplier))
					GameState.remove_from_inventory(sub_id, sub_units_needed)


func _grant_reward() -> void:
	var reward_seed: String = _current_quest.get("reward_seed", "") as String
	if reward_seed == "":
		return
	GameState.discover_seed(reward_seed)
	GameState.add_to_inventory(reward_seed, 4)

	var lore_index: int = _current_quest.get("reward_lore_fragment", -1) as int
	if lore_index >= 0 and lore_index not in GameState.lore_fragments:
		GameState.lore_fragments.append(lore_index)
