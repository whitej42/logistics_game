extends Node

## Game time, as a day number plus a decimal hour (6.5 = 06:30).
## Register as the "GameClock" autoload.

signal time_advanced(day: int, hour: float)
signal day_started(day: int)

## Game seconds per real second. 60 = one game minute per real second.
@export var time_scale: float = 60.0
@export var paused: bool = false

var day: int = 1
var hour: float = 0.0

func _process(delta: float) -> void:
	if paused:
		return
	advance(delta * time_scale / 3600.0)

## Moves time forward. Tests call this directly to skip ahead.
func advance(hours: float) -> void:
	hour += hours
	while hour >= 24.0:
		hour -= 24.0
		day += 1
		day_started.emit(day)
	time_advanced.emit(day, hour)
