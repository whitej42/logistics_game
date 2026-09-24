class_name TestWorld
extends RefCounted

## Standard starting scenario for tests: one depot, truck and driver, plus a
## milk job (collect 2 pallets + a box at a farm, deliver to Store B on day 1
## and Store C on day 2). Tweak the returned objects to set up edge cases.

var pallet: CargoType
var box_type: CargoType
var milk: Commodity
var truck_type: VehicleType

var depot: Depot
var truck: Vehicle
var driver: Driver

var milk_pallet: CargoItem
var milk_pallet_2: CargoItem
var box: CargoItem

var collection: JobDrop
var delivery_b: JobDrop
var delivery_c: JobDrop
var job: Job

static func create() -> TestWorld:
	var w := TestWorld.new()

	w.pallet = load("res://data/blueprints/resources/cargo_types/pallet.tres")
	w.box_type = CargoType.new() # defaults are a 1-slot parcel
	w.milk = load("res://data/blueprints/resources/commodities/milk.tres")
	w.truck_type = load("res://data/blueprints/resources/vehicle_types/truck.tres")

	w.depot = Depot.create("DEP_001", "Main Depot")
	w.depot.icon = load("res://assets/icons/warehouse.png")
	w.truck = Vehicle.create("VEH_001", w.truck_type, w.depot.depot_id)
	w.depot.dock_vehicle(w.truck)
	w.driver = Driver.create("DRV_001", "Jane Doe", Driver.DriverLicence.TRUCK)

	w.milk_pallet = CargoItem.create("ITEM_001", w.pallet, "JOB_001", w.milk)
	w.milk_pallet_2 = CargoItem.create("ITEM_002", w.pallet, "JOB_001", w.milk)
	w.box = CargoItem.create("ITEM_003", w.box_type, "JOB_001")

	w.collection = JobDrop.create("DROP_001", "JOB_001", JobDrop.DropType.COLLECTION, "LOC_FARM_A", [w.milk_pallet, w.milk_pallet_2, w.box])
	w.delivery_b = JobDrop.create("DROP_002", "JOB_001", JobDrop.DropType.DELIVERY, "LOC_STORE_B", [w.milk_pallet, w.box])
	w.delivery_c = JobDrop.create("DROP_003", "JOB_001", JobDrop.DropType.DELIVERY, "LOC_STORE_C", [w.milk_pallet_2], 2)
	w.job = Job.create("JOB_001", "Omni Logistics", 4500, [w.collection, w.delivery_b, w.delivery_c])
	return w

## A route for this world's driver and truck, timeline already calculated.
func make_route(route_id: String, day: int, drops: Array[JobDrop]) -> RoutePlan:
	var route := RoutePlan.create(route_id, day, depot.depot_id, driver, truck)
	for drop in drops:
		route.add_drop(drop)
	route.recalculate_timeline(6.0)
	return route
