class_name Vehicle
extends CargoContainer

enum VehicleStatus { IDLE, IN_TRANSIT, LOADING, UNLOADING, BROKEN }

@export var vehicle_id: String = "VEH_001"
@export var type: VehicleType # Points to a .tres blueprint (e.g. res://resources/vehicles/van.tres)
@export var current_location: String = "Main Depot"
@export var status: VehicleStatus = VehicleStatus.IDLE

@export var schedule: Array[Booking] = []

static func create(p_id: String, p_type: VehicleType, p_location: String) -> Vehicle:
	var v := Vehicle.new()
	v.vehicle_id = p_id
	v.type = p_type
	v.current_location = p_location
	return v

func get_total_slots () -> int:
	if type:
		return type.total_slots
	return super.get_total_slots()

func is_available_during(day: int, start_hour: float, end_hour: float) -> bool:
	if status == VehicleStatus.BROKEN:
		return false

	for booking in schedule:
		if booking.day == day:
			if booking.overlaps_with(day, start_hour, end_hour):
				return false
	
	return true

func book_route(route_id: String, day: int, start_hour: float, end_hour: float) -> bool:
	if not is_available_during(day, start_hour, end_hour):
		return false
	schedule.append(Booking.create(route_id, day, start_hour, end_hour))
	return true
