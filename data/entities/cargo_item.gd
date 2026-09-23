class_name CargoItem
extends Resource

@export var item_id: String = ""
@export var cargo_type: CargoType  # Blueprint: e.g. res://resources/cargo/pallet.tres (20 slots)
@export var commodity: Commodity   # Blueprint: e.g. res://resources/commodities/frozen_food.tres
@export var job_id: String = ""    # Links this specific payload back to its contract

# Helper to easily query slot cost on the live item
func get_slot_cost() -> int:
	return cargo_type.slots_required if cargo_type else 1
