extends Control

var player_labels: Array[Label] = []
var money_label: Label
var pause_menu: Control

func _ready():
    setup_player_labels()
    setup_money_display()
    setup_pause_menu()
    
    # Connect to money changes
    if GameManager:
        GameManager.player_money_changed.connect(_on_money_changed)

func setup_player_labels():
    # Player 1 label (top-left)
    var p1_label = Label.new()
    p1_label.text = "Player 1 (WS + AD + Space)"
    p1_label.position = Vector2(10, 10)
    p1_label.add_theme_color_override("font_color", Color.GREEN)
    add_child(p1_label)
    player_labels.append(p1_label)
    
    # Player 2 label (top-right)
    var p2_label = Label.new()
    p2_label.text = "Player 2 (Up/Down + L/R + Enter)"
    p2_label.position = Vector2(650, 10)
    p2_label.add_theme_color_override("font_color", Color.BLUE)
    add_child(p2_label)
    player_labels.append(p2_label)
    
    # Instructions
    var instructions = Label.new()
    instructions.text = "Destroy the other tank to win the round!\nMove: W/S - Up/Down | Rotate: A/D - Left/Right | Fire: Space/Enter\nCycle Weapons: Shift/Ctrl | Pause: ESC"
    instructions.position = Vector2(200, 50)
    instructions.add_theme_color_override("font_color", Color.WHITE)
    add_child(instructions)

func setup_money_display():
    money_label = Label.new()
    money_label.text = "Money: $1000"
    money_label.position = Vector2(10, 100)
    money_label.add_theme_color_override("font_color", Color.YELLOW)
    money_label.add_theme_font_size_override("font_size", 24)
    add_child(money_label)

func setup_pause_menu():
    var pause_scene = preload("res://scripts/ui/PauseMenu.gd")
    pause_menu = Control.new()
    pause_menu.set_script(pause_scene)
    add_child(pause_menu)
    
    pause_menu.resume_game.connect(_on_resume_game)
    pause_menu.restart_game.connect(_on_restart_game)
    pause_menu.return_to_menu.connect(_on_return_to_menu)

func _input(event):
    if event.is_action_pressed("ui_cancel") and not pause_menu.is_visible_in_tree():
        pause_menu.show_pause_menu()

func _on_resume_game():
    # Game automatically resumes via pause menu
    pass

func _on_restart_game():
    get_tree().reload_current_scene()

func _on_return_to_menu():
    GameManager.scene_manager.change_scene("res://scenes/menus/MainMenu.tscn")

func _on_money_changed(new_amount: int):
    if money_label:
        money_label.text = "Money: $%d" % new_amount