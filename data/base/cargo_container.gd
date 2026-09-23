class_name CargoContainer
extends Resource

@export var slot_count: int = 60
@export var stored_cargo: Array[CargoItem] = []

func get_total_slots () -> int:
	return slot_count

func get_used_slots() -> int:
	var total = 0
	for item in stored_cargo:
		total += item.get_slot_cost()
	return total

func get_remaining_slots() -> int:
	return get_total_slots() - get_used_slots()

func can_fit(cargo_item: CargoItem) -> bool:
	if cargo_item == null:
		return false
	return cargo_item.get_slot_cost() <= get_remaining_slots()

func has_cargo_for_job(job_id: String) -> bool:
	for item in stored_cargo:
		if item and item.job_id == job_id:
			return true
	return false

# WORKERS

func load_cargo(cargo_item: CargoItem) -> bool:
	if cargo_item == null or not can_fit(cargo_item):
		return false
	stored_cargo.append(cargo_item)
	return true

func unload_cargo(cargo_item: CargoItem) -> bool:
	if cargo_item == null:
		return false

	var index: int = stored_cargo.find(cargo_item)
	if index != -1:
		stored_cargo.remove_at(index)
		return true
	return false

func unload_cargo_for_job(job_id: String) -> Array[CargoItem]:
	var unloaded: Array[CargoItem] = []
	var remaining: Array[CargoItem] = []
	
	for item in stored_cargo:
		if item and item.job_id == job_id:
			unloaded.append(item)
		else:
			remaining.append(item)

	stored_cargo = remaining
	return unloaded
