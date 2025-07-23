extends Control

signal resume_game
signal restart_game
signal return_to_menu

@onready var resume_button: Button
@onready var restart_button: Button
@onready var menu_button: Button

func _ready():
	setup_ui()
	connect_signals()
	set_visible(false)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func setup_ui():
	# Set up full screen layout
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create semi-transparent background
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	main_container.position = Vector2(362, 250)
	main_container.size = Vector2(300, 300)
	main_container.add_theme_constant_override("separation", 20)
	add_child(main_container)
	
	# Pause title
	var title_label = Label.new()
	title_label.text = "PAUSED"
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color.YELLOW)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(title_label)
	
	# Resume button
	resume_button = Button.new()
	resume_button.text = "RESUME"
	resume_button.add_theme_font_size_override("font_size", 20)
	resume_button.custom_minimum_size = Vector2(200, 50)
	main_container.add_child(resume_button)
	
	# Restart button
	restart_button = Button.new()
	restart_button.text = "RESTART"
	restart_button.add_theme_font_size_override("font_size", 20)
	restart_button.custom_minimum_size = Vector2(200, 50)
	main_container.add_child(restart_button)
	
	# Menu button
	menu_button = Button.new()
	menu_button.text = "MAIN MENU"
	menu_button.add_theme_font_size_override("font_size", 20)
	menu_button.custom_minimum_size = Vector2(200, 50)
	main_container.add_child(menu_button)

func connect_signals():
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func show_pause_menu():
	set_visible(true)
	GameManager.pause_game()

func hide_pause_menu():
	set_visible(false)
	GameManager.unpause_game()

func _input(event):
	if event.is_action_pressed("ui_cancel") and is_visible_in_tree():
		_on_resume_pressed()

func _on_resume_pressed():
	print("Resuming game...")
	hide_pause_menu()
	resume_game.emit()

func _on_restart_pressed():
	print("Restarting game...")
	hide_pause_menu()
	restart_game.emit()

func _on_menu_pressed():
	print("Returning to main menu...")
	hide_pause_menu()
	return_to_menu.emit()