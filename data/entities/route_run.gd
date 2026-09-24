class_name RouteRun
extends RefCounted

## What actually happens on the day for one committed route. RoutePlan only
## estimates; this works out each next event from when the last one really happened.

enum Stage { NOT_STARTED, DRIVING, AT_STOP, RETURNING, FINISHED }

var route: RoutePlan
var depot: Depot

var stage: Stage = Stage.NOT_STARTED
var current_stop: int = 0
var next_event_hour: float = 0.0

static func create(p_route: RoutePlan, p_depot: Depot) -> RouteRun:
	var r := RouteRun.new()
	r.route = p_route
	r.depot = p_depot
	r.next_event_hour = p_route.start_hour
	return r

func is_finished() -> bool:
	return stage == Stage.FINISHED

## Catches up on every event due by this time. Safe to call every tick, and
## handles big clock jumps. Each next event is timed from when the previous
## one was due, not from the current clock, so jumps don't drift the schedule.
func update(day: int, hour: float) -> void:
	while stage != Stage.FINISHED and _has_reached(day, hour, next_event_hour):
		var event_hour := next_event_hour
		match stage:
			Stage.NOT_STARTED:
				_start()
				_drive_to_next(event_hour)

			Stage.DRIVING:
				_arrive(current_stop, event_hour)
				# Early? Wait for the window to open, then spend the dwell time.
				var card := route.action_cards[current_stop]
				next_event_hour = maxf(event_hour, card.window_start) + RoutePlan.DWELL_HOURS
				stage = Stage.AT_STOP

			Stage.AT_STOP:
				_depart(current_stop)
				current_stop += 1
				_drive_to_next(event_hour)

			Stage.RETURNING:
				_finish()
				stage = Stage.FINISHED

func _drive_to_next(from_hour: float) -> void:
	var from_id := depot.depot_id if current_stop == 0 else route.action_cards[current_stop - 1].location_id
	var to_id: String
	if current_stop < route.action_cards.size():
		to_id = route.action_cards[current_stop].location_id
		stage = Stage.DRIVING
	else:
		to_id = depot.depot_id
		stage = Stage.RETURNING
	next_event_hour = from_hour + route.get_travel_time(from_id, to_id)

# ponytail: a route running past midnight fires its remaining events at the day
# rollover; track day + hour per event if routes ever cross midnight.
func _has_reached(day: int, hour: float, target_hour: float) -> bool:
	if day > route.day:
		return true
	if day == route.day:
		return hour >= target_hour
	return false


# --- EVENTS: what happens to the world at each moment ---

## Leaving the depot.
func _start() -> void:
	pass

## Truck reaches stop i. arrival_hour < the card's window_start means it waits.
func _arrive(i: int, arrival_hour: float) -> void:
	pass

## Stop i's work is done and the truck drives off.
func _depart(i: int) -> void:
	pass

## Back at the depot.
func _finish() -> void:
	pass
