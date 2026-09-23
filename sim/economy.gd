extends Node

var money: float = 100

func add_cash(amount: int) -> void:
	money += amount

func deduct_cash(amount: int) -> bool:
	if money >= amount:  
		money -= amount
		return true

	# Allow debt
	money -= amount
	return false
