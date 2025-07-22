extends Node
class_name EventBus

signal tank_spawned(tank: Node, player_id: int)
signal tank_destroyed(tank: Node, player_id: int)
signal tank_damaged(tank: Node, damage: int, source: Node)
signal tank_healed(tank: Node, amount: int)

signal weapon_fired(weapon: Node, projectile: Node, tank: Node)
signal weapon_hit(weapon: Node, target: Node, damage: int)
signal weapon_purchased(weapon_data: Dictionary, player_id: int)
signal weapon_equipped(weapon: Node, tank: Node, slot: int)

signal round_started(round_number: int)
signal round_ended(round_number: int, winner: int)
signal battle_started(participants: Array)
signal battle_ended(results: Dictionary)

signal money_earned(player_id: int, amount: int, reason: String)
signal money_spent(player_id: int, amount: int, item: String)

signal ui_element_selected(element_name: String)
signal ui_menu_opened(menu_name: String)
signal ui_menu_closed(menu_name: String)

signal power_up_spawned(power_up: Node, position: Vector2)
signal power_up_collected(power_up: Node, tank: Node)

signal audio_play_sound(sound_name: String, position: Vector2)
signal audio_play_music(track_name: String, fade_in: bool)
signal audio_stop_music(fade_out: bool)

var event_history: Array[Dictionary] = []
var max_history_size: int = 1000

func _ready():
    print("EventBus initialized")

func emit_custom_signal(signal_name: String, data: Dictionary = {}):
    var event = {
        "signal": signal_name,
        "data": data,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    add_to_history(event)
    print("Custom event emitted: %s" % signal_name)

func add_to_history(event: Dictionary):
    event_history.append(event)
    if event_history.size() > max_history_size:
        event_history.pop_front()

func get_events_by_signal(signal_name: String) -> Array[Dictionary]:
    var filtered_events: Array[Dictionary] = []
    for event in event_history:
        if event.get("signal", "") == signal_name:
            filtered_events.append(event)
    return filtered_events

func get_recent_events(seconds: float) -> Array[Dictionary]:
    var cutoff_time = Time.get_unix_time_from_system() - seconds
    var recent_events: Array[Dictionary] = []
    
    for event in event_history:
        if event.get("timestamp", 0) >= cutoff_time:
            recent_events.append(event)
    
    return recent_events

func clear_history():
    event_history.clear()
    print("Event history cleared")

func connect_to_signal(signal_name: String, callable_target: Callable):
    if has_signal(signal_name):
        var signal_object = get(signal_name)
        if signal_object is Signal:
            signal_object.connect(callable_target)
            print("Connected to signal: %s" % signal_name)
    else:
        print("Warning: Signal %s does not exist on EventBus" % signal_name)

func disconnect_from_signal(signal_name: String, callable_target: Callable):
    if has_signal(signal_name):
        var signal_object = get(signal_name)
        if signal_object is Signal:
            signal_object.disconnect(callable_target)
            print("Disconnected from signal: %s" % signal_name)

func emit_tank_spawned(tank: Node, player_id: int):
    tank_spawned.emit(tank, player_id)
    add_to_history({"signal": "tank_spawned", "tank": tank, "player_id": player_id, "timestamp": Time.get_unix_time_from_system()})

func emit_tank_destroyed(tank: Node, player_id: int):
    tank_destroyed.emit(tank, player_id) 
    add_to_history({"signal": "tank_destroyed", "tank": tank, "player_id": player_id, "timestamp": Time.get_unix_time_from_system()})

func emit_weapon_fired(weapon: Node, projectile: Node, tank: Node):
    weapon_fired.emit(weapon, projectile, tank)
    add_to_history({"signal": "weapon_fired", "weapon": weapon, "projectile": projectile, "tank": tank, "timestamp": Time.get_unix_time_from_system()})

func emit_round_started(round_number: int):
    round_started.emit(round_number)
    add_to_history({"signal": "round_started", "round_number": round_number, "timestamp": Time.get_unix_time_from_system()})

func emit_round_ended(round_number: int, winner: int):
    round_ended.emit(round_number, winner)
    add_to_history({"signal": "round_ended", "round_number": round_number, "winner": winner, "timestamp": Time.get_unix_time_from_system()})

func emit_money_earned(player_id: int, amount: int, reason: String):
    money_earned.emit(player_id, amount, reason)
    add_to_history({"signal": "money_earned", "player_id": player_id, "amount": amount, "reason": reason, "timestamp": Time.get_unix_time_from_system()})

func emit_audio_play_sound(sound_name: String, position: Vector2 = Vector2.ZERO):
    audio_play_sound.emit(sound_name, position)
    
func emit_audio_play_music(track_name: String, fade_in: bool = false):
    audio_play_music.emit(track_name, fade_in)

func get_statistics() -> Dictionary:
    var stats = {
        "total_events": event_history.size(),
        "event_types": {},
        "recent_events_1min": get_recent_events(60.0).size(),
        "recent_events_5min": get_recent_events(300.0).size()
    }
    
    for event in event_history:
        var signal_name = event.get("signal", "unknown")
        if signal_name in stats.event_types:
            stats.event_types[signal_name] += 1
        else:
            stats.event_types[signal_name] = 1
    
    return stats