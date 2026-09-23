class_name Job
extends Resource

enum JobStatus { AVAILABLE, ACTIVE, COMPLETED, EXPIRED }

@export var job_id: String = "JOB_001"
@export var client_name: String = "Omni Logistics Corp"
@export var payout: int = 4500
@export var status: JobStatus = JobStatus.AVAILABLE

@export var drops: Array[JobDrop] = []


# --- INSPECTORS ---

func is_fully_delivered() -> bool:
	if drops.is_empty():
		return false
	for drop in drops:
		if drop and not drop.is_delivered:
			return false
	return true

func has_any_late_deliveries(current_time: float) -> bool:
	for drop in drops:
		if drop and drop.is_delivery_late(current_time):
			return true
	return false

# Gets all pending cargo items across all drops for this job
func get_all_manifest_items() -> Array[CargoItem]:
	var items: Array[CargoItem] = []
	for drop in drops:
		if drop:
			for item in drop.cargo_manifest:
				if item and not items.has(item):
					items.append(item)
	return items


# --- WORKERS ---

func update_status(current_time: float) -> void:
	if is_fully_delivered():
		status = JobStatus.COMPLETED
