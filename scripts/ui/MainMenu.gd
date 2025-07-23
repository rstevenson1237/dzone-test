extends Control

@onready var start_button: Button
@onready var options_button: Button
@onready var quit_button: Button
@onready var title_label: Label

func _ready():
	setup_ui()
	connect_signals()

func setup_ui():
	# Set up full screen layout
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create background
	var background = ColorRect.new()
	background.color = Color.BLACK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# Create title
	title_label = Label.new()
	title_label.text = "DESTRUCTION ZONE"
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color.GREEN)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position = Vector2(412, 150)
	title_label.size = Vector2(200, 60)
	add_child(title_label)
	
	# Create subtitle
	var subtitle = Label.new()
	subtitle.text = "Modern Recreation"
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color.CYAN)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(412, 220)
	subtitle.size = Vector2(200, 30)
	add_child(subtitle)
	
	# Create buttons container
	var button_container = VBoxContainer.new()
	button_container.position = Vector2(412, 300)
	button_container.size = Vector2(200, 200)
	button_container.add_theme_constant_override("separation", 20)
	add_child(button_container)
	
	# Start Game button
	start_button = Button.new()
	start_button.text = "START GAME"
	start_button.add_theme_font_size_override("font_size", 24)
	start_button.custom_minimum_size = Vector2(200, 50)
	button_container.add_child(start_button)
	
	# Options button (placeholder)
	options_button = Button.new()
	options_button.text = "OPTIONS"
	options_button.add_theme_font_size_override("font_size", 24)
	options_button.custom_minimum_size = Vector2(200, 50)
	button_container.add_child(options_button)
	
	# Quit button
	quit_button = Button.new()
	quit_button.text = "QUIT"
	quit_button.add_theme_font_size_override("font_size", 24)
	quit_button.custom_minimum_size = Vector2(200, 50)
	button_container.add_child(quit_button)
	
	# Add instructions
	var instructions = Label.new()
	instructions.text = "Tank Combat • Weapon Shop • Economy System"
	instructions.add_theme_font_size_override("font_size", 16)
	instructions.add_theme_color_override("font_color", Color.YELLOW)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.position = Vector2(312, 550)
	instructions.size = Vector2(400, 30)
	add_child(instructions)

func connect_signals():
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	if GameManager.audio_manager:
		GameManager.audio_manager.play_ui_sound("button_click")
	print("Starting new game...")
	GameManager.start_new_game()

func _on_options_pressed():
	if GameManager.audio_manager:
		GameManager.audio_manager.play_ui_sound("button_click")
	print("Options menu not yet implemented")
	# TODO: Implement options menu

func _on_quit_pressed():
	if GameManager.audio_manager:
		GameManager.audio_manager.play_ui_sound("button_click")
	print("Quitting game...")
	GameManager.quit_game()