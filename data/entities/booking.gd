class_name Booking
extends Resource

@export var route_id: String = ""
@export var day: int = 1
@export var start_hour: float = 6.0
@export var end_hour: float = 15.0

## Factory constructor
static func create(p_route_id: String, p_day: int, p_start: float, p_end: float) -> Booking:
	var b = Booking.new()
	b.route_id = p_route_id
	b.day = p_day
	b.start_hour = p_start
	b.end_hour = p_end
	return b

func overlaps_with(check_day: int, check_start: float, check_end: float) -> bool:
	if day != check_day:
		return false
	# Standard range overlap check: (StartA < EndB) and (EndA > StartB)
	return check_start < end_hour and check_end > start_hour
