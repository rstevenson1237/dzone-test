extends Node
class_name InputManager

signal input_received(action: String, player_id: int)

const MAX_PLAYERS = 4

var input_maps = {
    0: {  # Player 1
        "move_up": "p1_move_up",
        "move_down": "p1_move_down", 
        "move_left": "p1_move_left",
        "move_right": "p1_move_right",
        "rotate_left": "p1_rotate_left",
        "rotate_right": "p1_rotate_right",
        "fire": "p1_fire",
        "special": "p1_special"
    },
    1: {  # Player 2
        "move_up": "p2_move_up",
        "move_down": "p2_move_down",
        "move_left": "p2_move_left", 
        "move_right": "p2_move_right",
        "rotate_left": "p2_rotate_left",
        "rotate_right": "p2_rotate_right",
        "fire": "p2_fire",
        "special": "p2_special"
    }
}

var active_players = [true, false, false, false]

func _ready():
    print("InputManager initialized")
    setup_default_input_map()

func _input(event):
    for player_id in range(MAX_PLAYERS):
        if not active_players[player_id]:
            continue
            
        if player_id in input_maps:
            for action_name in input_maps[player_id]:
                var input_action = input_maps[player_id][action_name]
                if Input.is_action_pressed(input_action):
                    input_received.emit(action_name, player_id)

func get_movement_vector(player_id: int) -> Vector2:
    if player_id >= MAX_PLAYERS or not active_players[player_id]:
        return Vector2.ZERO
    
    var movement = Vector2.ZERO
    
    if player_id in input_maps:
        var actions = input_maps[player_id]
        if Input.is_action_pressed(actions["move_up"]):
            movement.y -= 1
        if Input.is_action_pressed(actions["move_down"]):
            movement.y += 1
        if Input.is_action_pressed(actions["move_left"]):
            movement.x -= 1
        if Input.is_action_pressed(actions["move_right"]):
            movement.x += 1
    
    return movement.normalized()

func get_rotation_input(player_id: int) -> float:
    if player_id >= MAX_PLAYERS or not active_players[player_id]:
        return 0.0
    
    var rotation = 0.0
    
    if player_id in input_maps:
        var actions = input_maps[player_id]
        if Input.is_action_pressed(actions["rotate_left"]):
            rotation -= 1.0
        if Input.is_action_pressed(actions["rotate_right"]):
            rotation += 1.0
    
    return rotation

func is_action_pressed(action: String, player_id: int) -> bool:
    if player_id >= MAX_PLAYERS or not active_players[player_id]:
        return false
    
    if player_id in input_maps and action in input_maps[player_id]:
        return Input.is_action_pressed(input_maps[player_id][action])
    
    return false

func is_action_just_pressed(action: String, player_id: int) -> bool:
    if player_id >= MAX_PLAYERS or not active_players[player_id]:
        return false
    
    if player_id in input_maps and action in input_maps[player_id]:
        return Input.is_action_just_pressed(input_maps[player_id][action])
    
    return false

func set_player_active(player_id: int, active: bool):
    if player_id < MAX_PLAYERS:
        active_players[player_id] = active
        print("Player %d set to %s" % [player_id + 1, "active" if active else "inactive"])

func setup_default_input_map():
    ensure_input_action_exists("p1_move_up", KEY_W)
    ensure_input_action_exists("p1_move_down", KEY_S) 
    ensure_input_action_exists("p1_move_left", KEY_A)
    ensure_input_action_exists("p1_move_right", KEY_D)
    ensure_input_action_exists("p1_rotate_left", KEY_Q)
    ensure_input_action_exists("p1_rotate_right", KEY_E)
    ensure_input_action_exists("p1_fire", KEY_SPACE)
    ensure_input_action_exists("p1_special", KEY_SHIFT)
    
    ensure_input_action_exists("p2_move_up", KEY_UP)
    ensure_input_action_exists("p2_move_down", KEY_DOWN)
    ensure_input_action_exists("p2_move_left", KEY_LEFT)
    ensure_input_action_exists("p2_move_right", KEY_RIGHT)
    ensure_input_action_exists("p2_rotate_left", KEY_COMMA)
    ensure_input_action_exists("p2_rotate_right", KEY_PERIOD)
    ensure_input_action_exists("p2_fire", KEY_ENTER)
    ensure_input_action_exists("p2_special", KEY_CTRL)

func ensure_input_action_exists(action_name: String, key_code: int):
    if not InputMap.has_action(action_name):
        InputMap.add_action(action_name)
        var event = InputEventKey.new()
        event.keycode = key_code
        InputMap.action_add_event(action_name, event)
        print("Added input action: %s -> %s" % [action_name, OS.get_keycode_string(key_code)])