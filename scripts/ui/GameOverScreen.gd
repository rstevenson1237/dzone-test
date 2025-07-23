extends Control

signal restart_game
signal return_to_menu

@onready var title_label: Label
@onready var winner_label: Label
@onready var score_label: Label
@onready var restart_button: Button
@onready var menu_button: Button

var game_results: Dictionary = {}

func _ready():
	setup_ui()
	connect_signals()
	set_visible(false)

func setup_ui():
	# Set up full screen layout
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create semi-transparent background
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.8)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	main_container.position = Vector2(312, 200)
	main_container.size = Vector2(400, 400)
	main_container.add_theme_constant_override("separation", 30)
	add_child(main_container)
	
	# Game Over title
	title_label = Label.new()
	title_label.text = "GAME OVER"
	title_label.add_theme_font_size_override("font_size", 42)
	title_label.add_theme_color_override("font_color", Color.RED)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(title_label)
	
	# Winner announcement
	winner_label = Label.new()
	winner_label.text = "Player 1 Wins!"
	winner_label.add_theme_font_size_override("font_size", 28)
	winner_label.add_theme_color_override("font_color", Color.GREEN)
	winner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(winner_label)
	
	# Score display
	score_label = Label.new()
	score_label.text = "Player 1: 3 wins\nPlayer 2: 2 wins"
	score_label.add_theme_font_size_override("font_size", 20)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(score_label)
	
	# Button container
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 20)
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_container.add_child(button_container)
	
	# Restart button
	restart_button = Button.new()
	restart_button.text = "PLAY AGAIN"
	restart_button.add_theme_font_size_override("font_size", 20)
	restart_button.custom_minimum_size = Vector2(150, 50)
	button_container.add_child(restart_button)
	
	# Menu button
	menu_button = Button.new()
	menu_button.text = "MAIN MENU"
	menu_button.add_theme_font_size_override("font_size", 20)
	menu_button.custom_minimum_size = Vector2(150, 50)
	button_container.add_child(menu_button)

func connect_signals():
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func show_game_over(results: Dictionary):
	game_results = results
	update_display()
	set_visible(true)

func update_display():
	if game_results.has("winner"):
		var winner_id = game_results.winner
		if winner_id >= 0:
			winner_label.text = "Player %d Wins!" % (winner_id + 1)
			winner_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			winner_label.text = "Draw Game!"
			winner_label.add_theme_color_override("font_color", Color.YELLOW)
	
	if game_results.has("scores"):
		var score_text = ""
		var scores = game_results.scores
		for player_id in scores:
			score_text += "Player %d: %d wins\n" % [player_id + 1, scores[player_id]]
		score_label.text = score_text.strip_edges()

func _on_restart_pressed():
	print("Restarting game...")
	restart_game.emit()

func _on_menu_pressed():
	print("Returning to main menu...")
	return_to_menu.emit()