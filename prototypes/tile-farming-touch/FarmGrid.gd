# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does touch-based tile farming feel satisfying on mobile?
# Date: 2026-03-27

extends Node2D

var cols: int = 6
var rows: int = 8
var tile_size: int = 56
var tile_gap: int = 4

var tiles: Array[Node] = []

# Preload the CropTile script — new() used since no .tscn for prototype
const CropTileScript = preload("res://CropTile.gd")


func setup(c: int, r: int, size: int, gap: int) -> void:
	cols = c
	rows = r
	tile_size = size
	tile_gap = gap

	# Center the grid on screen
	var total_w: float = cols * (tile_size + tile_gap) - tile_gap
	var total_h: float = rows * (tile_size + tile_gap) - tile_gap
	var viewport_size: Vector2 = get_viewport_rect().size
	position = Vector2(
		(viewport_size.x - total_w) / 2.0,
		(viewport_size.y - total_h) / 2.0 - 60  # leave room for UI at bottom
	)

	_spawn_tiles()


func _spawn_tiles() -> void:
	for row in rows:
		for col in cols:
			var tile := Node2D.new()
			tile.set_script(CropTileScript)
			add_child(tile)
			tile.setup(tile_size)
			tile.position = Vector2(
				col * (tile_size + tile_gap),
				row * (tile_size + tile_gap)
			)
			tile.connect("harvested", _on_tile_harvested.bind(tile))
			tiles.append(tile)


func advance_day() -> void:
	for tile in tiles:
		tile.advance_day()


func _on_tile_harvested(_tile: Node2D) -> void:
	# Bubble up to Main
	get_parent().on_crop_harvested()
