class_name Driver
extends Resource

enum DriverStatus {WORKING, IDLE, AT_HOME, SICK, HOLIDAY}
enum DriverLicence {VAN, TRUCK}

@export var driver_id: String = "DRV_001"
@export var driver_name: String = "Jane Doe"
@export var status: DriverStatus = DriverStatus.IDLE
@export var licence: DriverLicence = DriverLicence.VAN

@export var schedule: Array[Booking] = []

static func create(p_id: String, p_name: String, p_licence: DriverLicence) -> Driver:
	var d := Driver.new()
	d.driver_id = p_id
	d.driver_name = p_name
	d.licence = p_licence
	return d

func is_available_during(day: int, start_hour: float, end_hour: float) -> bool:
	if status == DriverStatus.SICK or status == DriverStatus.HOLIDAY:
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
