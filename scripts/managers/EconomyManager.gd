extends Node
class_name EconomyManager

signal money_changed(new_amount: int)

var player_money: int = 1000

func _ready():
    print("EconomyManager initialized")

func add_money(amount: int):
    player_money += amount
    money_changed.emit(player_money)

func spend_money(amount: int) -> bool:
    if player_money >= amount:
        player_money -= amount
        money_changed.emit(player_money)
        return true
    return false

func get_money() -> int:
    return player_money

func set_money(amount: int):
    player_money = amount
    money_changed.emit(player_money)
