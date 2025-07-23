extends Node2D

@export var respawn_delay: float = 3.0
@export var max_rounds: int = 5

var tanks: Array[Tank] = []
var spawn_positions: Array[Vector2] = []
var current_round: int = 1
var round_winners: Array[int] = []

func _ready():
    setup_arena()
    setup_spawn_positions()
    connect_tank_signals()

func setup_arena():
    print("Arena Manager initialized - Round %d/%d" % [current_round, max_rounds])

func setup_spawn_positions():
    # Define spawn positions for up to 6 players
    spawn_positions = [
        Vector2(300, 300),  # Player 1
        Vector2(700, 300),  # Player 2
        Vector2(300, 500),  # Player 3
        Vector2(700, 500),  # Player 4
        Vector2(500, 200),  # Player 5
        Vector2(500, 600)   # Player 6
    ]

func connect_tank_signals():
    # Find all tank nodes and connect their signals
    tanks.clear()
    for child in get_children():
        if child is Tank:
            tanks.append(child)
            child.tank_destroyed.connect(_on_tank_destroyed)
            print("Connected Tank %d" % (child.player_id + 1))

func _on_tank_destroyed(tank: Tank):
    print("Tank %d destroyed in arena!" % (tank.player_id + 1))
    
    # Check for round end
    check_round_end()
    
    # Schedule respawn if round isn't over
    if get_alive_tanks().size() > 1:
        schedule_respawn(tank)

func get_alive_tanks() -> Array[Tank]:
    var alive_tanks: Array[Tank] = []
    for tank in tanks:
        if is_instance_valid(tank):
            alive_tanks.append(tank)
    return alive_tanks

func check_round_end():
    var alive_tanks = get_alive_tanks()
    
    if alive_tanks.size() <= 1:
        # Round over - award money
        if alive_tanks.size() == 1:
            var winner = alive_tanks[0]
            print("Round %d winner: Player %d!" % [current_round, winner.player_id + 1])
            round_winners.append(winner.player_id)
            award_round_money(winner.player_id)
        else:
            print("Round %d: Draw!" % current_round)
            round_winners.append(-1)  # Draw
            award_draw_money()
        
        # Start next round or end game
        if current_round < max_rounds:
            open_weapon_shop()
        else:
            end_game()

func schedule_respawn(tank: Tank):
    var timer = Timer.new()
    timer.wait_time = respawn_delay
    timer.one_shot = true
    add_child(timer)
    
    timer.timeout.connect(func(): respawn_tank(tank.player_id); timer.queue_free())
    timer.start()
    
    print("Tank %d will respawn in %.1f seconds" % [tank.player_id + 1, respawn_delay])

func respawn_tank(player_id: int):
    if player_id >= spawn_positions.size():
        return
    
    # Create new tank
    var tank_scene = preload("res://scenes/tanks/Tank.tscn")
    var new_tank = tank_scene.instantiate()
    new_tank.player_id = player_id
    new_tank.global_position = spawn_positions[player_id]
    
    add_child(new_tank)
    new_tank.tank_destroyed.connect(_on_tank_destroyed)
    
    # Update tanks array
    for i in range(tanks.size()):
        if tanks[i].player_id == player_id:
            tanks[i] = new_tank
            break
    
    print("Tank %d respawned!" % (player_id + 1))

func start_next_round():
    current_round += 1
    print("\n=== Starting Round %d/%d ===" % [current_round, max_rounds])
    
    # Respawn all destroyed tanks
    var alive_tank_ids = []
    for tank in get_alive_tanks():
        alive_tank_ids.append(tank.player_id)
    
    for i in range(2):  # For 2 players
        if i not in alive_tank_ids:
            respawn_tank(i)

func end_game():
    print("\n=== GAME OVER ===")
    var scores = {}
    
    # Count wins per player
    for winner_id in round_winners:
        if winner_id >= 0:
            scores[winner_id] = scores.get(winner_id, 0) + 1
    
    print("Final Scores:")
    for player_id in scores:
        print("Player %d: %d wins" % [player_id + 1, scores[player_id]])
    
    # Find overall winner
    var max_wins = 0
    var game_winner = -1
    for player_id in scores:
        if scores[player_id] > max_wins:
            max_wins = scores[player_id]
            game_winner = player_id
    
    if game_winner >= 0:
        print("GAME WINNER: Player %d!" % (game_winner + 1))
    else:
        print("GAME DRAW!")
    
    # Restart after delay
    var timer = Timer.new()
    timer.wait_time = 5.0
    timer.one_shot = true
    add_child(timer)
    timer.timeout.connect(func(): restart_game(); timer.queue_free())
    timer.start()

func award_round_money(winner_player_id: int):
    var base_reward = 200
    var round_bonus = current_round * 50  # More money in later rounds
    var total_reward = base_reward + round_bonus
    
    GameManager.add_money(total_reward)
    print("Player %d earned $%d for winning round %d!" % [winner_player_id + 1, total_reward, current_round])

func award_draw_money():
    var draw_reward = 50
    GameManager.add_money(draw_reward)
    print("Draw - both players earn $%d" % draw_reward)

func award_kill_money(killer_player_id: int):
    var kill_reward = 25
    GameManager.add_money(kill_reward)
    print("Player %d earned $%d for elimination!" % [killer_player_id + 1, kill_reward])

func open_weapon_shop():
    print("Opening weapon shop between rounds...")
    
    var shop_scene = preload("res://scripts/ui/WeaponShop.gd")
    var shop = Control.new()
    shop.set_script(shop_scene)
    
    get_tree().current_scene.add_child(shop)
    shop.shop_closed.connect(_on_shop_closed)
    shop.weapon_purchased.connect(_on_weapon_purchased)

func _on_shop_closed():
    print("Shop closed, starting next round...")
    start_next_round()

func _on_weapon_purchased(weapon_data: Dictionary):
    print("Weapon purchased: %s" % weapon_data.name)
    
    # Find the first alive tank (for simplicity, assume Player 1 gets the weapon)
    var alive_tanks = get_alive_tanks()
    if alive_tanks.size() > 0:
        var tank = alive_tanks[0]
        if tank.weapon_manager:
            var new_weapon = tank.weapon_manager.create_weapon_from_data(weapon_data)
            tank.weapon_manager.add_weapon(new_weapon)
            print("Added %s to Player %d's arsenal" % [weapon_data.name, tank.player_id + 1])

func restart_game():
    print("Restarting game...")
    get_tree().reload_current_scene()