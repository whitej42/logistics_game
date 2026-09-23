class_name DepotProcessing
extends Node

# Performs an atomic, single-item transfer between any two CargoContainers
static func transfer_cargo(from: CargoContainer, to: CargoContainer, item: CargoItem) -> bool:
	if from == null or to == null or item == null:
		return false

	if not from.stored_cargo.has(item):
		return false
	if not to.can_fit(item):
		return false
		
	if from.unload_cargo(item):
		if to.load_cargo(item):
			return true
		else:
			# If loading failed for any reason, re-add to source
			from.load_cargo(item)

	return false
