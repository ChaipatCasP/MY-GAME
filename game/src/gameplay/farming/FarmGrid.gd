extends Node2D
## FarmGrid — manages the 6×8 grid of CropTile nodes.
## Placed in the farm scene. Connects to DayManager for growth ticks.

const COLS: int = 6
const ROWS: int = 8
const TILE_SIZE: float = 56.0
const TILE_GAP: float = 4.0

var _tiles: Array[CropTile] = []


func _ready() -> void:
	DayManager.day_advanced.connect(_on_day_advanced)
	_build_grid()


func _build_grid() -> void:
	var total_w: float = COLS * (TILE_SIZE + TILE_GAP) - TILE_GAP
	var total_h: float = ROWS * (TILE_SIZE + TILE_GAP) - TILE_GAP
	var origin: Vector2 = Vector2(
		(390.0 - total_w) / 2.0,
		(844.0 - total_h) / 2.0
	)
	for row: int in range(ROWS):
		for col: int in range(COLS):
			var tile: CropTile = CropTile.new()
			tile.col = col
			tile.row = row
			tile.position = origin + Vector2(
				col * (TILE_SIZE + TILE_GAP),
				row * (TILE_SIZE + TILE_GAP)
			)
			tile.tile_size = TILE_SIZE
			tile.harvested.connect(_on_tile_harvested.bind(tile))
			add_child(tile)
			_tiles.append(tile)


func _on_day_advanced(_new_day: int) -> void:
	for tile: CropTile in _tiles:
		tile.advance_day()


## Returns the tile at grid coordinates (col, row), or null if out of bounds.
func get_tile(col: int, row: int) -> CropTile:
	if col < 0 or col >= COLS or row < 0 or row >= ROWS:
		return null
	return _tiles[row * COLS + col]


func _on_tile_harvested(tile: CropTile) -> void:
	GameState.add_to_inventory(tile.crop_id, tile.crop_yield)


## Serialise tile states into GameState.farm_tiles for SaveSystem.
func serialize() -> void:
	GameState.farm_tiles.clear()
	for tile: CropTile in _tiles:
		var key: String = "%d_%d" % [tile.col, tile.row]
		GameState.farm_tiles[key] = tile.to_dict()


## Restore tile states from GameState.farm_tiles after a load.
func deserialize() -> void:
	for tile: CropTile in _tiles:
		var key: String = "%d_%d" % [tile.col, tile.row]
		if GameState.farm_tiles.has(key):
			tile.from_dict(GameState.farm_tiles[key] as Dictionary)
