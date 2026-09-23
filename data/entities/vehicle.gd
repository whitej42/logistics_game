class_name Vehicle
extends CargoContainer

enum VehicleStatus { IDLE, IN_TRANSIT, LOADING, UNLOADING }

@export var vehicle_id: String = "VEH_001"
@export var type: VehicleType # Points to a .tres blueprint (e.g. res://resources/vehicles/van.tres)
@export var current_location: String = "Main Depot"
@export var status: VehicleStatus = VehicleStatus.IDLE

func get_total_slots () -> int:
	if type:
		return type.total_slots
	return super.get_total_slots()
