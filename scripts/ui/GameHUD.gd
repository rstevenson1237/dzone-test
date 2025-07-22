extends Control

var player_labels: Array[Label] = []

func _ready():
    setup_player_labels()

func setup_player_labels():
    # Player 1 label (top-left)
    var p1_label = Label.new()
    p1_label.text = "Player 1 (WASD + Space)"
    p1_label.position = Vector2(10, 10)
    p1_label.add_theme_color_override("font_color", Color.GREEN)
    add_child(p1_label)
    player_labels.append(p1_label)
    
    # Player 2 label (top-right)
    var p2_label = Label.new()
    p2_label.text = "Player 2 (Arrows + Enter)"
    p2_label.position = Vector2(700, 10)
    p2_label.add_theme_color_override("font_color", Color.BLUE)
    add_child(p2_label)
    player_labels.append(p2_label)
    
    # Instructions
    var instructions = Label.new()
    instructions.text = "Destroy the other tank to win the round!\nMove: WASD/Arrows | Rotate: QE/,. | Fire: Space/Enter"
    instructions.position = Vector2(250, 50)
    instructions.add_theme_color_override("font_color", Color.WHITE)
    add_child(instructions)