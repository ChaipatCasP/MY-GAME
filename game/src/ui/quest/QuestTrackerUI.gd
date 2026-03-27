extends CanvasLayer
## QuestTrackerUI — shows the active spirit quest requirements and delivery state.
## Updates live via inventory_changed signal.

@onready var spirit_name_label: Label = $Panel/VBox/SpiritNameLabel
@onready var quest_text_label: Label = $Panel/VBox/QuestTextLabel
@onready var requirements_container: VBoxContainer = $Panel/VBox/Requirements
@onready var deliver_button: Button = $Panel/VBox/DeliverButton
@onready var status_label: Label = $Panel/VBox/StatusLabel


func _ready() -> void:
	SpiritQuestSystem.quest_loaded.connect(_on_quest_loaded)
	SpiritQuestSystem.quest_completed.connect(_on_quest_completed)
	SpiritQuestSystem.delivery_failed.connect(_on_delivery_failed)
	GameState.inventory_changed.connect(_on_inventory_changed)

	# Populate immediately for the starting island.
	_refresh()


func _on_quest_loaded(_island_id: String) -> void:
	_refresh()


func _on_quest_completed(_island_id: String) -> void:
	status_label.text = "Quest complete!"
	status_label.modulate = Color(0.3, 0.85, 0.4)
	deliver_button.visible = false
	_refresh_requirements()


func _on_delivery_failed(missing_crops: Dictionary) -> void:
	var parts: Array[String] = []
	for crop_id: Variant in missing_crops.keys():
		parts.append("%d more %s" % [missing_crops[crop_id], crop_id])
	status_label.text = "Need: " + ", ".join(parts)
	status_label.modulate = Color(0.9, 0.3, 0.3)


func _on_inventory_changed(_crop_id: String, _new_count: int) -> void:
	_refresh_requirements()


func _on_deliver_button_pressed() -> void:
	SpiritQuestSystem.attempt_delivery()


func _refresh() -> void:
	var island_id: String = GameState.current_island_id
	var island: Dictionary = IslandDatabase.get_island(island_id)
	if island.is_empty():
		return

	var spirit: Dictionary = island.get("spirit", {}) as Dictionary
	spirit_name_label.text = "%s — %s" % [spirit.get("name", ""), spirit.get("title", "")]

	var quest_state: SpiritQuestSystem.QuestState = SpiritQuestSystem.get_state()
	var dialogue_key: String = SpiritQuestSystem.get_dialogue_key()
	quest_text_label.text = spirit.get(dialogue_key, "") as String
	quest_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var is_completed: bool = quest_state == SpiritQuestSystem.QuestState.COMPLETED
	deliver_button.visible = not is_completed
	status_label.text = "Quest complete!" if is_completed else ""
	status_label.modulate = Color(0.3, 0.85, 0.4) if is_completed else Color.WHITE

	_refresh_requirements()


func _refresh_requirements() -> void:
	# Clear previous requirement rows.
	for child: Node in requirements_container.get_children():
		child.queue_free()

	var required: Array = SpiritQuestSystem.get_required_crops()
	var island: Dictionary = IslandDatabase.get_island(GameState.current_island_id)
	var quest: Dictionary = island.get("quest", {}) as Dictionary
	var substitutions: Array = quest.get("substitutions", []) as Array

	for req: Variant in required:
		var req_dict: Dictionary = req as Dictionary
		var crop_id: String = req_dict.get("crop_id", "") as String
		var needed: int = req_dict.get("amount", 0) as int
		var have: int = GameState.inventory_count(crop_id)

		# Add substitution counts if applicable.
		for sub: Variant in substitutions:
			var sub_dict: Dictionary = sub as Dictionary
			if (sub_dict.get("counts_as", "") as String) == crop_id:
				var sub_crop: String = sub_dict.get("crop_id", "") as String
				var multiplier: int = sub_dict.get("multiplier", 1) as int
				have += GameState.inventory_count(sub_crop) * multiplier

		var row: Label = Label.new()
		var met: bool = have >= needed
		row.text = "%s: %d / %d" % [crop_id.capitalize().replace("_", " "), min(have, needed), needed]
		row.modulate = Color(0.3, 0.85, 0.4) if met else Color(0.9, 0.6, 0.2)
		row.theme_override_font_sizes["font_size"] = 18
		requirements_container.add_child(row)

	# Enable/disable deliver button based on readiness.
	if deliver_button.visible:
		deliver_button.disabled = not SpiritQuestSystem.can_deliver()
