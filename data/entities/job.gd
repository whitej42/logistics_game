class_name Job
extends Resource

## Owns the whole flow. Drops only know their own stop; the job links them
## through shared CargoItems (each item is collected once and delivered once).

enum JobStatus { AVAILABLE, ACTIVE, COMPLETED, EXPIRED }

@export var job_id: String = "JOB_001"
@export var client_name: String = "Omni Logistics Corp"
@export var payout: int = 4500
@export var status: JobStatus = JobStatus.AVAILABLE

@export var drops: Array[JobDrop] = []

static func create(p_id: String, p_client: String, p_payout: int, p_drops: Array[JobDrop]) -> Job:
	var j := Job.new()
	j.job_id = p_id
	j.client_name = p_client
	j.payout = p_payout
	j.drops = p_drops
	return j

# --- INSPECTORS ---

func is_complete() -> bool:
	if drops.is_empty():
		return false
	for drop in drops:
		if drop and not drop.is_completed:
			return false
	return true

func has_any_late_drops(current_day: int, current_hour: float) -> bool:
	for drop in drops:
		if drop and drop.is_late(current_day, current_hour):
			return true
	return false

func get_all_manifest_items() -> Array[CargoItem]:
	var items: Array[CargoItem] = []
	for drop in drops:
		if drop:
			for item in drop.cargo_manifest:
				if item and not items.has(item):
					items.append(item)
	return items

func get_collection_drop_for(item: CargoItem) -> JobDrop:
	return _find_drop_for(item, JobDrop.DropType.COLLECTION)

func get_delivery_drop_for(item: CargoItem) -> JobDrop:
	return _find_drop_for(item, JobDrop.DropType.DELIVERY)

## Collected but not yet delivered, e.g. waiting in a depot for a later route.
func get_items_in_transit() -> Array[CargoItem]:
	var items: Array[CargoItem] = []
	for item in get_all_manifest_items():
		var collection := get_collection_drop_for(item)
		var delivery := get_delivery_drop_for(item)
		if collection and collection.is_completed and delivery and not delivery.is_completed:
			items.append(item)
	return items

## Every item must be collected exactly once and delivered exactly once.
func validate() -> Array[String]:
	var errors: Array[String] = []
	for item in get_all_manifest_items():
		var collections := _count_drops_for(item, JobDrop.DropType.COLLECTION)
		var deliveries := _count_drops_for(item, JobDrop.DropType.DELIVERY)
		if collections != 1:
			errors.append("Item '%s' is collected %d times (expected 1)" % [item.item_id, collections])
		if deliveries != 1:
			errors.append("Item '%s' is delivered %d times (expected 1)" % [item.item_id, deliveries])
	return errors


# --- WORKERS ---

func update_status() -> void:
	if is_complete():
		status = JobStatus.COMPLETED


func _find_drop_for(item: CargoItem, drop_type: JobDrop.DropType) -> JobDrop:
	for drop in drops:
		if drop and drop.type == drop_type and drop.cargo_manifest.has(item):
			return drop
	return null

func _count_drops_for(item: CargoItem, drop_type: JobDrop.DropType) -> int:
	var count := 0
	for drop in drops:
		if drop and drop.type == drop_type and drop.cargo_manifest.has(item):
			count += 1
	return count
