extends Node2D
## CropTile — a single farmable plot in a 6×8 grid.
## Handles player tap (plant/water/harvest) and daily growth.

signal harvested(tile: Node)  # emitted when player harvests; carries self

enum State { EMPTY, SEEDED, GROWING, HARVESTABLE }

## Set by FarmGrid during construction.
var col: int = 0
var row: int = 0
var tile_size: float = 56.0

## Set when a seed is planted.
var crop_id: String = ""
var crop_yield: int = 0
var crop_base_grow_days: int = 0
var crop_season_affinity: String = ""

## Runtime state.
var state: State = State.EMPTY
var days_grown: int = 0
var is_watered_today: bool = false

var _bg: ColorRect


func _ready() -> void:
	_bg = ColorRect.new()
	_bg.size = Vector2(tile_size, tile_size)
	_bg.color = _color_for_state(state)
	add_child(_bg)


## Called by FarmGrid on each day advance.
func advance_day() -> void:
	if state == State.GROWING:
		if is_watered_today:
			days_grown += 1
		is_watered_today = false
		var effective_days: int = _effective_grow_days()
		if days_grown >= effective_days:
			state = State.HARVESTABLE
	elif state == State.SEEDED:
		# Seed was planted but never watered — stays SEEDED until watered.
		is_watered_today = false
	_refresh_visual()


func _effective_grow_days() -> int:
	var penalty: int = 0
	if crop_season_affinity != "" and crop_season_affinity != GameState.current_island_id:
		# TODO: compare season string after Island system resolves current season
		penalty = 1
	return crop_base_grow_days + penalty


## Handle player input: tap to interact.
func _input(event: InputEvent) -> void:
	if not _is_tap(event):
		return
	var tap_pos: Vector2 = Vector2.ZERO
	if event is InputEventScreenTouch:
		tap_pos = (event as InputEventScreenTouch).position
	elif event is InputEventMouseButton:
		tap_pos = (event as InputEventMouseButton).position
	if not Rect2(global_position, Vector2(tile_size, tile_size)).has_point(tap_pos):
		return
	get_viewport().set_input_as_handled()
	_handle_tap()


func _is_tap(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		return mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed
	return false


func _handle_tap() -> void:
	match state:
		State.EMPTY:
			_try_plant()
		State.SEEDED, State.GROWING:
			_water()
		State.HARVESTABLE:
			_harvest()


func _try_plant() -> void:
	# Seed selection UI will set the pending seed; for now auto-pick first known seed.
	# TODO: integrate with SeedSelectionUI when that system is implemented.
	if GameState.known_seeds.is_empty():
		return
	var seed_id: String = GameState.known_seeds[0]
	if GameState.inventory_count(seed_id) <= 0:
		return
	var crop_data: Dictionary = CropDatabase.get_crop(seed_id)
	if crop_data.is_empty():
		return
	GameState.remove_from_inventory(seed_id, 1)
	crop_id = seed_id
	crop_yield = crop_data.get("yield", 1) as int
	crop_base_grow_days = crop_data.get("grow_days", 2) as int
	crop_season_affinity = crop_data.get("season_affinity", "") as String
	days_grown = 0
	state = State.SEEDED
	_refresh_visual()


func _water() -> void:
	if is_watered_today:
		return  # Idempotent — watering twice does nothing
	is_watered_today = true
	if state == State.SEEDED:
		state = State.GROWING
	AudioManager.play_sfx("water")
	_refresh_visual()


func _harvest() -> void:
	state = State.EMPTY
	harvested.emit(self)
	AudioManager.play_sfx("harvest")
	crop_id = ""
	crop_yield = 0
	crop_base_grow_days = 0
	crop_season_affinity = ""
	days_grown = 0
	is_watered_today = false
	_refresh_visual()


func _refresh_visual() -> void:
	if _bg != null:
		_bg.color = _color_for_state(state)


func _color_for_state(s: State) -> Color:
	match s:
		State.EMPTY:      return Color(0.45, 0.30, 0.18)  # Brown soil
		State.SEEDED:     return Color(0.55, 0.40, 0.22)  # Lighter soil
		State.GROWING:    return Color(0.25, 0.60, 0.30)  # Green
		State.HARVESTABLE: return Color(0.85, 0.75, 0.20) # Gold
	return Color.WHITE


## Serialisation helpers used by FarmGrid.
func to_dict() -> Dictionary:
	return {
		"state": int(state),
		"crop_id": crop_id,
		"crop_yield": crop_yield,
		"crop_base_grow_days": crop_base_grow_days,
		"crop_season_affinity": crop_season_affinity,
		"days_grown": days_grown,
		"is_watered_today": is_watered_today,
	}


func from_dict(data: Dictionary) -> void:
	state = data.get("state", 0) as State
	crop_id = data.get("crop_id", "") as String
	crop_yield = data.get("crop_yield", 0) as int
	crop_base_grow_days = data.get("crop_base_grow_days", 0) as int
	crop_season_affinity = data.get("crop_season_affinity", "") as String
	days_grown = data.get("days_grown", 0) as int
	is_watered_today = data.get("is_watered_today", false) as bool
	_refresh_visual()
