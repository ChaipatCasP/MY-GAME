extends Node
## GameState — global game state autoload
## Holds the single source of truth for all persistent game data.
## Other systems read from here; only SaveSystem writes to here on load.

signal island_changed(new_island_id: String)
signal inventory_changed(crop_id: String, new_count: int)

const VERSION: int = 1  # Increment when save format changes

var current_day: int = 1
var current_island_id: String = "island_spring"

## Inventory: crop_id -> count
var inventory: Dictionary = {}

## Known seeds: array of crop_ids the player has discovered
var known_seeds: Array[String] = ["clover"]

## Completed quests: array of island_ids where quest was fulfilled
var completed_quests: Array[String] = []

## Lore fragments unlocked: array of fragment indices
var lore_fragments: Array[int] = []

## Farm grid tile states — serialised by SaveSystem
## Key: "col_row" e.g. "2_3", Value: Dictionary (see CropTile)
var farm_tiles: Dictionary = {}


func add_to_inventory(crop_id: String, amount: int) -> void:
	inventory[crop_id] = (inventory.get(crop_id, 0) as int) + amount
	inventory_changed.emit(crop_id, inventory[crop_id] as int)


func remove_from_inventory(crop_id: String, amount: int) -> bool:
	var current: int = inventory.get(crop_id, 0) as int
	if current < amount:
		return false
	inventory[crop_id] = current - amount
	if inventory[crop_id] == 0:
		inventory.erase(crop_id)
	inventory_changed.emit(crop_id, inventory.get(crop_id, 0) as int)
	return true


func discover_seed(crop_id: String) -> bool:
	if crop_id in known_seeds:
		return false
	known_seeds.append(crop_id)
	return true


func inventory_count(crop_id: String) -> int:
	return inventory.get(crop_id, 0) as int


func total_seeds_held() -> int:
	var total: int = 0
	for count: Variant in inventory.values():
		total += count as int
	return total
