class_name Depot
extends CargoContainer

@export var depot_id: String = "DEP_001"
@export var depot_name: String = "Main Depot"

@export var docked_vehicles: Array[Vehicle] = []

@export var icon: Texture2D

# New depot start with 600 slots
func _init() -> void:
	slot_count = 600

static func create(p_id: String, p_name: String) -> Depot:
	var d := Depot.new()
	d.depot_id = p_id
	d.depot_name = p_name
	return d

func dock_vehicle(vehicle: Vehicle) -> bool:
	if vehicle == null or docked_vehicles.has(vehicle):
		return true
	docked_vehicles.append(vehicle)
	vehicle.current_location = depot_id
	return true

func undock_vehicle(vehicle: Vehicle) -> bool:
	if vehicle == null:
		return false
		
	var index: int = docked_vehicles.find(vehicle)
	if index != -1:
		docked_vehicles.remove_at(index)
		return true
	return false
