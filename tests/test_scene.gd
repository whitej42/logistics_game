extends Node2D

const POS_DEPOT: Vector2 = Vector2(800, 350)
const POS_COLLECTION: Vector2 = Vector2(200, 350)
const POS_DELIVERY: Vector2 = Vector2(400, 350)

@onready var col_node: ColorRect = $Collection
@onready var del_node: ColorRect = $Delivery

@onready var depot_node: Sprite2D = $DepotSprite
@onready var truck_node: Sprite2D = $TruckSprite
@onready var pallet_node: Sprite2D = $PalletSprite
@onready var milk_node: Sprite2D = $PalletSprite/MilkSprite

var is_moving: bool = false

func _ready() -> void:
	var w := TestWorld.create()
	assert(w.job.validate().is_empty(), "job invalid: %s" % [w.job.validate()])

	# Day 1: collect everything, deliver to B. Pallet 2 comes home to the depot.
	var route_1 := w.make_route("RT_101", 1, [w.collection, w.delivery_b])
	var committed_1 := route_1.commit_route(w.depot.stored_cargo)
	assert(committed_1, "route 1 failed to commit")

	for item in w.collection.cargo_manifest:
		w.truck.load_cargo(item)
	var collected := w.collection.try_complete("LOC_FARM_A", w.truck)
	assert(collected, "collection not completed")
	var expected_slots := w.pallet.slots_required * 2 + w.box_type.slots_required
	assert(w.truck.get_used_slots() == expected_slots, "expected %d slots on board" % expected_slots)
	w.truck.unload_cargo(w.milk_pallet)
	w.truck.unload_cargo(w.box)
	var delivered_b := w.delivery_b.try_complete("LOC_STORE_B", w.truck)
	assert(delivered_b, "delivery B not completed")
	var cross_docked := DepotProcessing.transfer_cargo(w.truck, w.depot, w.milk_pallet_2)
	assert(cross_docked, "cross-dock to depot failed")
	var in_transit := w.job.get_items_in_transit()
	assert(in_transit.size() == 1 and in_transit.has(w.milk_pallet_2), "pallet 2 should be in transit")

	# Day 2 can't deliver pallet 2 unless the depot is holding it.
	var route_2 := w.make_route("RT_102", 2, [w.delivery_c])
	assert(not route_2.validate_sequence().is_empty(), "route 2 should fail without depot stock")
	var committed_2 := route_2.commit_route(w.depot.stored_cargo)
	assert(committed_2, "route 2 failed to commit")

	assert(w.driver.schedule.size() == 2, "driver should have 2 bookings")
	assert(w.truck.schedule.size() == 2, "truck should have 2 bookings")
	assert(not w.job.is_complete(), "job finished too early")
	print_rich("All checks passed")

	depot_node.texture = w.depot.icon
	truck_node.texture = w.truck.type.icon
	pallet_node.texture = w.milk_pallet.cargo_type.icon
	milk_node.texture = w.milk_pallet.commodity.icon
