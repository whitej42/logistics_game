class_name JobDrop
extends Resource

enum DropType { PICKUP, DELIVERY }

@export var drop_id: String = "DROP_001"
@export var job_id: String = "JOB_001"
@export var location: String = ""
@export var type: DropType = DropType.PICKUP

# Target waypoints
@export var origin_id: String = "LOC_FACTORY_A"
@export var destination_id: String = "LOC_STORE_B"

# Time Windows (In game time, e.g., total minutes/hours elapsed in game)
@export var pickup_window_start: float = 0.0
@export var pickup_window_end: float = 0.0
@export var delivery_window_start: float = 0.0
@export var delivery_window_end: float = 0.0

# Cargo tied to this specific drop requirement
@export var cargo_manifest: Array[CargoItem] = []
@export var is_completed: bool = false

# Status flags
@export var is_picked_up: bool = false
@export var is_delivered: bool = false


# --- TIME SLA CHECKS ---

func is_pickup_window_open(current_time: float) -> bool:
	return current_time >= pickup_window_start and current_time <= pickup_window_end

func is_delivery_window_open(current_time: float) -> bool:
	return current_time >= delivery_window_start and current_time <= delivery_window_end

func is_pickup_late(current_time: float) -> bool:
	return not is_picked_up and current_time > pickup_window_end

func is_delivery_late(current_time: float) -> bool:
	return not is_delivered and current_time > delivery_window_end


# --- FULFILLMENT VERIFICATION ---

# Called when unloading cargo at any location. Marks completed ONLY if at final destination.
func check_delivery_at_location(location_id: String, container: CargoContainer) -> bool:
	if is_delivered:
		return true
	if container == null or location_id != destination_id:
		return false # Just cross-docking at an intermediate depot!

	# Check if ALL items in the manifest are inside this location's container
	for item in cargo_manifest:
		if item and not container.stored_cargo.has(item):
			return false
			
	is_delivered = true
	return true
