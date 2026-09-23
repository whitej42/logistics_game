class_name Depot
extends CargoContainer

@export var depot_id: String = "DEP_001"
@export var depot_name: String = "Main Depot"
@export var total_slots: int = 600

@export var docked_vehicles: Array[Vehicle] = []

func dock_vehicle(vehicle: Vehicle) -> bool:
	if vehicle == null or docked_vehicles.has(vehicle):
		return true
	docked_vehicles.append(vehicle)
	vehicle.current_location = depot_id
	return true

func undock_vehicle(vehicle: Vehicle) -> bool:
	if vehicle == null:
		return false
		
	var index: int = vehicle.find(vehicle)
	if index != -1:
		docked_vehicles.remove_at(index)
		return true
	return false
