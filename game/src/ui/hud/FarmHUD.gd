extends CanvasLayer
## FarmHUD — persistent overlay shown during farming.
## Displays day counter and harvest count. Houses the "Next Day" button.

@onready var day_label: Label = $DayLabel
@onready var harvest_label: Label = $HarvestLabel
@onready var next_day_btn: Button = $NextDayButton

var _total_harvested: int = 0


func _ready() -> void:
	DayManager.day_advanced.connect(_on_day_advanced)
	_refresh_day_label(GameState.current_day)


func _on_day_advanced(new_day: int) -> void:
	_refresh_day_label(new_day)


func _refresh_day_label(day: int) -> void:
	if day_label != null:
		day_label.text = "Day %d" % day


func increment_harvest(amount: int) -> void:
	_total_harvested += amount
	if harvest_label != null:
		harvest_label.text = "Harvested: %d" % _total_harvested


func _on_next_day_button_pressed() -> void:
	DayManager.request_advance()
