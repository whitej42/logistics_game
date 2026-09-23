class_name Commodity
extends Resource

@export var commodity_id: String = "frozen_food"
@export var display_name: String = "Frozen Produce"
@export var default_cargo_type: CargoType  # Points to res://resources/cargo/pallet.tres
@export var requires_refrigeration: bool = true
