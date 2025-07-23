extends Control

var player_labels: Array[Label] = []
var money_label: Label

func _ready():
    setup_player_labels()
    setup_money_display()
    
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
    instructions.text = "Destroy the other tank to win the round!\nMove: W/S - Up/Down | Rotate: A/D - Left/Right | Fire: Space/Enter\nCycle Weapons: Shift/Ctrl"
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

func _on_money_changed(new_amount: int):
    if money_label:
        money_label.text = "Money: $%d" % new_amount