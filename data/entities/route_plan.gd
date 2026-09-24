class_name RoutePlan
extends Resource

@export var route_id: String = "RT_101"
@export var day: int = 1
@export var depot_id: String = "LOC_MAIN_DEPOT"

@export var assigned_driver: Driver
@export var assigned_vehicle: Vehicle

@export var action_cards: Array[JobDrop] = []

var estimated_start_hour: float= 0.0
var estimated_end_hour: float= 0.0

static func create(p_id: String, p_day: int, p_depot_id: String, p_driver: Driver, p_vehicle: Vehicle) -> RoutePlan:
	var r := RoutePlan.new()
	r.route_id = p_id
	r.day = p_day
	r.depot_id = p_depot_id
	r.assigned_driver = p_driver
	r.assigned_vehicle = p_vehicle
	return r

func add_drop(drop: JobDrop) -> bool:
	if drop == null:
		return false
	action_cards.append(drop)
	return true

func remove_drop(drop: JobDrop) -> bool:
	if drop == null or not action_cards.has(drop):
		return false
	action_cards.erase(drop)
	return true

## Inserts a card at a specific position in the route sequence
func insert_drop(drop: JobDrop, index: int) -> bool:
	if drop == null or index < 0 or index > action_cards.size():
		return false
	action_cards.insert(index, drop)
	return true

## Reorders a card from one list position to another (e.g. drag & drop)
func move_drop(from_index: int, to_index: int) -> bool:
	if from_index < 0 or from_index >= action_cards.size():
		return false
	if to_index < 0 or to_index >= action_cards.size():
		return false
	if from_index == to_index:
		return true
		
	var card = action_cards[from_index]
	action_cards.remove_at(from_index)
	action_cards.insert(to_index, card)
	return true

## Simulates the cargo on board stop by stop. Returns human-readable errors.
## depot_stock: items waiting at the depot (e.g. collected on an earlier route);
## any the route delivers are loaded at the start.
func validate_sequence(depot_stock: Array[CargoItem] = []) -> Array[String]:
	var errors: Array[String] = []
	var on_board := get_start_load(depot_stock)
	var capacity := assigned_vehicle.get_total_slots() if assigned_vehicle else 0

	for i in range(action_cards.size()):
		var card := action_cards[i]
		for item in card.cargo_manifest:
			match card.type:
				JobDrop.DropType.COLLECTION:
					if on_board.has(item):
						errors.append("Row #%d: '%s' is already on board" % [i + 1, item.item_id])
					else:
						on_board.append(item)
				JobDrop.DropType.DELIVERY:
					if on_board.has(item):
						on_board.erase(item)
					else:
						errors.append("Row #%d: '%s' is not on board to deliver" % [i + 1, item.item_id])

		var used := 0
		for item in on_board:
			used += item.get_slot_cost()
		if assigned_vehicle and used > capacity:
			errors.append("Row #%d: %d slots on board, vehicle holds %d" % [i + 1, used, capacity])
	return errors

## What's on board leaving the depot: the vehicle's current cargo plus any
## depot stock this route delivers without collecting it first.
func get_start_load(depot_stock: Array[CargoItem] = []) -> Array[CargoItem]:
	var start_load: Array[CargoItem] = []
	if assigned_vehicle:
		start_load.append_array(assigned_vehicle.stored_cargo)

	var collected_here: Array[CargoItem] = []
	for card in action_cards:
		for item in card.cargo_manifest:
			if card.type == JobDrop.DropType.COLLECTION:
				collected_here.append(item)
			elif not collected_here.has(item) and not start_load.has(item) and depot_stock.has(item):
				start_load.append(item)
	return start_load

## Calculates full loop timeline: Depot -> Action Cards -> Depot Return
func recalculate_timeline(start_hour: float, location_graph: Dictionary = {}) -> void:
	estimated_start_hour = start_hour
	var current_time: float = start_hour
	var current_loc: String = depot_id
	
	# 1. Process all action cards (Pickups & Deliveries)
	for card in action_cards:
		var target_loc = card.location_id
		if target_loc != current_loc:
			current_time += _get_travel_time(current_loc, target_loc, location_graph)
			current_loc = target_loc
		current_time += 0.25 # 15 min dwell/loading time
		
	# 2. IMPLICIT RETURN TO DEPOT: Always add final return leg home
	if current_loc != depot_id:
		current_time += _get_travel_time(current_loc, depot_id, location_graph)
		current_loc = depot_id
		
	estimated_end_hour = current_time


func _get_travel_time(from_id: String, to_id: String, location_graph: Dictionary) -> float:
	if location_graph.has(from_id) and location_graph[from_id].has(to_id):
		return location_graph[from_id][to_id]
	return 0.5 # Default 30 min travel fallback


func commit_route(depot_stock: Array[CargoItem] = []) -> bool:
	var validation_errors = validate_sequence(depot_stock)
	if not validation_errors.is_empty():
		push_error("Cannot commit route %s: %s" % [route_id, validation_errors[0]])
		return false
		
	if not assigned_driver or not assigned_vehicle:
		push_error("Cannot commit route %s: needs a driver and a vehicle" % route_id)
		return false

	# Check both first so a failure never leaves only one of them booked.
	if not assigned_driver.is_available_during(day, estimated_start_hour, estimated_end_hour):
		push_error("Cannot commit route %s: driver %s is unavailable" % [route_id, assigned_driver.driver_id])
		return false
	if not assigned_vehicle.is_available_during(day, estimated_start_hour, estimated_end_hour):
		push_error("Cannot commit route %s: vehicle %s is unavailable" % [route_id, assigned_vehicle.vehicle_id])
		return false

	assigned_driver.book_route(route_id, day, estimated_start_hour, estimated_end_hour)
	assigned_vehicle.book_route(route_id, day, estimated_start_hour, estimated_end_hour)
	print("Route %s committed: %.2fh to %.2fh (Returns to %s)" % [route_id, estimated_start_hour, estimated_end_hour, depot_id])
	return true
