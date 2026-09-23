extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_rich("[color=yellow]=== LOGISTICS SIMULATION CONSOLE TEST ===[/color]\n")
	print_money()
	run_simulation_test()

func run_simulation_test() -> void:
	var player_yard = Depot.new("Main Yard", 10)
	print_rich("[color=cyan][WAREHOUSE][/color] Created: %s (Cap: %d)" % [player_yard.location_name, player_yard.storage_capacity])

	# Create Cargo
	var steel = Cargo.new()
	steel.cargo_name = "Steel Beams"
	steel.weight_kg = 4000
	steel.payout = 550

	var corn = Cargo.new()
	corn.cargo_name = "Corn Pallet"
	corn.weight_kg = 150
	corn.payout = 80

	var parcel = Cargo.new()
	parcel.cargo_name = "Parcel"
	parcel.weight_kg = 10
	parcel.payout = 25

	var cargo_list: Array[Cargo] = [steel, corn, parcel]

	# Create Vehicles
	var inbound_vehicle = Vehicle.new()
	inbound_vehicle.type = "Big Truck"
	inbound_vehicle.capacity = 10
	inbound_vehicle.loaded_cargo = cargo_list

	var outbound_vehicle = Vehicle.new()
	outbound_vehicle.type = "Small Truck"
	outbound_vehicle.capacity = 2

	while not inbound_vehicle.loaded_cargo.is_empty():
		var cargo = inbound_vehicle.unload_first_item() 
		player_yard.load_cargo(cargo)
		print_rich("[color=cyan][WAREHOUSE][/color] Cargo %s unloaded from supplier" % cargo.cargo_name)

	# Loop through cargo items
	var i = 0
	while i < player_yard.stored_cargo.size():
		var cargo = player_yard.stored_cargo[i]

		# Check if fits on vehicle
		if outbound_vehicle.load_cargo(cargo):
			player_yard.unload_cargo(cargo)
			print_rich("[color=blue][VEHICLE][/color] Cargo %s loaded" % cargo.cargo_name)
		else:
			# Skip cargo item if doesn't fit on vehicle
			print_rich("[color=red][VEHICLE][/color] Cargo %s is too heavy or vehicle is full!" % cargo.cargo_name)
			i += 1

	var dispatch_cost: float = 50
	Economy.deduct_cash(dispatch_cost)
	print_money()

	# Delivery behavior
	while not outbound_vehicle.loaded_cargo.is_empty():
		var cargo = outbound_vehicle.unload_first_item()
		Economy.add_cash(cargo.payout)

	print_money()

	print_rich("\n[color=yellow]=== TEST COMPLETE ===[/color]")

func print_money() -> void:
	print_rich("\n[color=green][BANK][/color] £%d" % Economy.money)
