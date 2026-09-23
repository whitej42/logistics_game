# res://data/vehicle_type.gd
class_name VehicleType
extends Resource

@export var type_id: String = "van"
@export var display_name: String = "Delivery Van"
@export var total_slots: int = 60 # Always 60 for all vans
