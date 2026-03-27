extends Node
## Boot — first scene. Initialises global systems and loads the Farm scene.

func _ready() -> void:
	# Attempt to restore a saved game. Falls through to new game if no save.
	var loaded: bool = SaveSystem.load_save()
	if not loaded:
		_start_new_game()
	get_tree().change_scene_to_file("res://src/gameplay/farm/FarmScene.tscn")


func _start_new_game() -> void:
	GameState.current_day = 1
	GameState.current_island_id = "island_spring"
	GameState.known_seeds = ["clover"]
	GameState.add_to_inventory("clover", 6)  # Starter seeds
