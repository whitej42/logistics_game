extends Node2D

# --- Configuration Constants ---
const VEHICLE_CAPACITY: int = 3
const PRICE_PER_DROP: int = 100
const FUEL_COST_PER_PIXEL: float = 0.008

const SIZE_NODE: Vector2 = Vector2(60, 60)
const SIZE_VEHICLE: Vector2 = Vector2(24, 24)

const POS_DEPOT: Vector2 = Vector2(800, 350)
const POS_PICKUP: Vector2 = Vector2(200, 350)

# Offset required to center a 24x24 vehicle inside a 60x60 node
const VEHICLE_OFFSET: Vector2 = (SIZE_NODE - SIZE_VEHICLE) / 2.0

# --- Node References ---
@onready var ui_label: Label = $UILabel
@onready var status_label: Label = $StatusLabel
@onready var pickup: ColorRect = $Pickup
@onready var depot: ColorRect = $Depot
@onready var vehicle: ColorRect = $Vehicle

# --- State Variables ---
var current_cargo: int = 0
var is_moving: bool = false
var deliveries: Array[ColorRect] = []


func _ready():
	_setup_nodes()
	update_ui()
	generate_random_deliveries()

func _input(event: InputEvent) -> void:
	# Click anywhere on screen to dispatch the vehicle
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_moving:
			start_multi_drop_route()

######################
## Core Route Logic ##
######################
func start_multi_drop_route() -> void:
	status_label.hide()
	is_moving = true

	vehicle.position = depot.position + Vector2(18, 18)
	var pickup_pos = pickup.position + Vector2(18, 18)
	var depot_pos = depot.position + Vector2(18, 18)

	var tween = vehicle.create_tween()
	var total_distance: float = 0.0
	var last_pos = vehicle.position # Last vehicle position
	var route_gross_earnings: int = 0

	# Duplicate the array so we can slice batches while keeping track of unassigned drops
	var remaining_deliveries = deliveries.duplicate()

	while not remaining_deliveries.is_empty():
		# Get the next batch of deliveries based on vehicle capacity
		var batch = remaining_deliveries.slice(0, VEHICLE_CAPACITY)
		remaining_deliveries = remaining_deliveries.slice(batch.size())

		# Drive to from pickup
		total_distance += last_pos.distance_to(pickup_pos)
		last_pos = pickup_pos

		# Collect cargo
		_add_leg_to_pickup(tween, pickup_pos, batch.size())

		# Deliver cargo to each drop in the batch
		for drop in batch:
			var delivery_pos = drop.position + Vector2(18, 18)
			total_distance += pickup_pos.distance_to(delivery_pos)
			last_pos = delivery_pos

			route_gross_earnings += PRICE_PER_DROP  # Add earnings for this drop

			_add_leg_to_drop(tween, delivery_pos, drop)

	# Calculate total distance and fuel cost
	total_distance += last_pos.distance_to(depot_pos)

	# Return to Depot
	_add_leg_to_depot(tween, depot_pos, total_distance, route_gross_earnings)


#######################
## Tween Helper Legs ##
#######################

func _add_leg_to_pickup(tween: Tween, pos: Vector2, cargo: int) -> void:
	tween.tween_property(vehicle, "position", pos, 1.2)
	tween.tween_callback(func(): _on_collect_cargo(cargo))
	tween.tween_interval(1.2)

func _add_leg_to_drop(tween: Tween, pos: Vector2, drop) -> void:
	tween.tween_property(vehicle, "position", pos, 1.2)
	tween.tween_callback(func(): _on_deliver_cargo(drop))
	tween.tween_interval(1.2)

func _add_leg_to_depot(tween: Tween, pos: Vector2, total_distance: float, gross: int) -> void:
	tween.tween_property(vehicle, "position", pos, 1.2)
	tween.tween_callback(func():
		var total_fuel = RouteCalculator.calculate_fuel_cost(total_distance, FUEL_COST_PER_PIXEL)
		var net_profit = RouteCalculator.calculate_profit(gross, total_fuel)
		var summary_text = RouteCalculator.format_route_earnings(gross, total_fuel, net_profit)
		show_status(summary_text, depot.position)
	)
	tween.tween_callback(generate_random_deliveries)
	tween.tween_callback(func(): is_moving = false)


##############################
## Cargo and Delivery Logic ##
##############################

func _on_collect_cargo(amount: int) -> void:
	current_cargo = amount
	show_status("Loading %d Cargo..." % amount, pickup.position)
	update_ui()

func _on_deliver_cargo(drop: ColorRect) -> void:
	Economy.add_cash(PRICE_PER_DROP)
	current_cargo -= 1
	deliveries.erase(drop)
	drop.queue_free()

	show_status("+£%d Earned!" % PRICE_PER_DROP, drop.position)
	update_ui()

func generate_random_deliveries() -> void:
	if not deliveries.is_empty():
		return

	var drop_count = randi_range(3, 10)

	for i in drop_count:
		var delivery = ColorRect.new()
		delivery.color = Color.INDIAN_RED
		delivery.size = Vector2(60, 60)
		delivery.position = Vector2(randi_range(100, 700), randi_range(100, 500))
		add_child(delivery)
		deliveries.append(delivery) # store in array

	update_ui()

##################
## Helpers & UI ##
##################

func _setup_nodes() -> void:
	# Setup positions
	depot.position = POS_DEPOT
	pickup.position = POS_PICKUP
	vehicle.position = depot.position + VEHICLE_OFFSET

	# Setup sizes
	depot.size = SIZE_NODE
	pickup.size = SIZE_NODE
	vehicle.size = SIZE_VEHICLE

	# Setup colors
	depot.color = Color.DODGER_BLUE
	pickup.color = Color.LIME_GREEN
	vehicle.color = Color.YELLOW
	vehicle.z_index = 10

	# UI Position
	ui_label.position = Vector2(50, 50)
	ui_label.add_theme_font_size_override("font_size", 28)
	update_ui()

	status_label.z_index = 12
	status_label.hide()
	status_label.add_theme_font_size_override("font_size", 16)

func show_status(msg: String, pos: Vector2) -> void:
	status_label.text = msg
	status_label.reset_size() # Forces Godot to recalculate label size based on new text
	
	# Positions text centered horizontally and padded 10px cleanly above the node
	var x_offset: float = -20.0
	var y_offset: float = -status_label.size.y - 10.0
	
	status_label.position = pos + Vector2(x_offset, y_offset)
	status_label.z_index = 20 # Ensures text always renders on top of nodes
	status_label.show()

func _get_center(node: Control) -> Vector2:
	return node.position + VEHICLE_OFFSET

func update_ui() -> void:
	ui_label.text = "Money: £%d | Capacity: %d | Cargo on Van: %d | Pending: %d" % [
		int(Economy.money), VEHICLE_CAPACITY, current_cargo, max(0, deliveries.size() - current_cargo)
	]
