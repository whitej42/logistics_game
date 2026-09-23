class_name RouteCalculator
extends Node

static func calculate_fuel_cost(distance: float, rate: float) -> int:
	return int(distance * rate)

static func calculate_profit(gross: int, fuel_cost: int) -> int:
	return gross - fuel_cost

static func format_route_earnings(gross: int, fuel: int, profit: int) -> String:
	return "Route Complete!\nGross: +£%d | Fuel: -£%d\nNet Profit: +£%d" % [gross, fuel, profit]
