extends Node
## DayManager — autoload that owns the in-game day cycle.
## The player taps "Next Day" → DayManager.advance_day() is called.
## All other systems listen to `day_advanced` signal.

## Emitted after every day advance. Carry new_day for convenience.
signal day_advanced(new_day: int)

## Prevents double-tap advances. Set to false after debounce expires.
var _advancing: bool = false
const DEBOUNCE_SECONDS: float = 0.3


## Called by the "Next Day" button in FarmHUD.
func request_advance() -> void:
	if _advancing:
		return
	_advancing = true
	advance_day()
	await get_tree().create_timer(DEBOUNCE_SECONDS).timeout
	_advancing = false


func advance_day() -> void:
	_tick_all_crops()
	_reset_water_flags()
	GameState.current_day += 1
	day_advanced.emit(GameState.current_day)


func _tick_all_crops() -> void:
	# Farm Grid Manager connects to this via the day_advanced signal.
	# CropTile growth is handled in FarmGrid._on_day_advanced().
	# DayManager does not reference FarmGrid directly — signal-only coupling.
	pass


func _reset_water_flags() -> void:
	# Farm Grid Manager resets water flags on all tiles when it receives
	# the day_advanced signal. Nothing to do here.
	pass
