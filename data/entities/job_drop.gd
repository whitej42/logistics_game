class_name JobDrop
extends Resource

## One stop: collect or deliver some cargo at one location within one time window.

enum DropType { COLLECTION, DELIVERY }

@export var drop_id: String = "DROP_001"
@export var job_id: String = "JOB_001"
@export var type: DropType = DropType.COLLECTION
@export var location_id: String = "LOC_STORE_A"

@export var day: int = 1
@export var window_start: float = 6.0
@export var window_end: float = 17.0

@export var cargo_manifest: Array[CargoItem] = []
@export var is_completed: bool = false

static func create(p_id: String, p_job_id: String, p_type: DropType, p_location_id: String, p_cargo: Array[CargoItem], p_day: int = 1, p_start: float = 6.0, p_end: float = 17.0) -> JobDrop:
	var d := JobDrop.new()
	d.drop_id = p_id
	d.job_id = p_job_id
	d.type = p_type
	d.location_id = p_location_id
	d.cargo_manifest = p_cargo
	d.day = p_day
	d.window_start = p_start
	d.window_end = p_end
	return d


# --- TIME WINDOW ---

func is_window_open(current_day: int, current_hour: float) -> bool:
	return current_day == day and current_hour >= window_start and current_hour <= window_end

func is_late(current_day: int, current_hour: float) -> bool:
	if is_completed:
		return false
	if current_day > day:
		return true
	return current_day == day and current_hour > window_end


# --- FULFILLMENT ---

## Marks the drop complete if the vehicle is here and its cargo matches:
## a collection needs every item on board, a delivery needs every item off.
func try_complete(at_location_id: String, vehicle: CargoContainer) -> bool:
	if is_completed:
		return true
	if vehicle == null or at_location_id != location_id:
		return false

	var want_on_board := type == DropType.COLLECTION
	for item in cargo_manifest:
		if item and vehicle.stored_cargo.has(item) != want_on_board:
			return false

	is_completed = true
	return true
