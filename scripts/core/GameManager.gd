extends Node

enum GameState {
    MAIN_MENU,
    IN_BATTLE,
    SHOP,
    GAME_OVER,
    PAUSED
}

signal game_state_changed(new_state: GameState)
signal player_money_changed(new_amount: int)
signal round_completed(round_number: int)

var current_state: GameState = GameState.MAIN_MENU
var player_money: int = 1000
var current_round: int = 1
var scene_manager: SceneManager
var economy_manager: EconomyManager
var input_manager: InputManager
var event_bus: EventBus

func _ready():
    setup_managers()
    print("GameManager initialized as singleton")

func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        quit_game()

func setup_managers():
    scene_manager = SceneManager.new()
    add_child(scene_manager)
    
    economy_manager = EconomyManager.new()
    add_child(economy_manager)
    
    input_manager = InputManager.new()
    add_child(input_manager)
    
    event_bus = EventBus.new()
    add_child(event_bus)
    
    connect_signals()

func connect_signals():
    if economy_manager:
        economy_manager.money_changed.connect(_on_money_changed)

func change_game_state(new_state: GameState):
    if current_state != new_state:
        var old_state = current_state
        current_state = new_state
        game_state_changed.emit(new_state)
        print("Game state changed from %s to %s" % [GameState.keys()[old_state], GameState.keys()[new_state]])

func add_money(amount: int):
    player_money += amount
    player_money_changed.emit(player_money)

func spend_money(amount: int) -> bool:
    if player_money >= amount:
        player_money -= amount
        player_money_changed.emit(player_money)
        return true
    return false

func start_new_game():
    current_round = 1
    player_money = 1000
    change_game_state(GameState.IN_BATTLE)
    scene_manager.change_scene("res://scenes/arena/Arena.tscn")

func complete_round():
    current_round += 1
    round_completed.emit(current_round)
    change_game_state(GameState.SHOP)

func quit_game():
    print("Quitting D-Zone Clone...")
    get_tree().quit()

func pause_game():
    get_tree().paused = true
    change_game_state(GameState.PAUSED)

func unpause_game():
    get_tree().paused = false
    change_game_state(GameState.IN_BATTLE)

func _on_money_changed(new_amount: int):
    player_money = new_amount
    player_money_changed.emit(player_money)
