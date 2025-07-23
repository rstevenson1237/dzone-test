extends Control

signal shop_closed()
signal weapon_purchased(weapon_data: Dictionary)

var available_weapons: Array[Dictionary] = []
var weapon_buttons: Array[Button] = []
var money_label: Label
var selected_weapon: Dictionary = {}

func _ready():
    setup_shop_ui()
    setup_available_weapons()
    update_money_display()

func setup_shop_ui():
    # Set up full screen layout
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    
    # Dark background with border
    var background = ColorRect.new()
    background.color = Color(0.05, 0.05, 0.15, 0.95)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)
    
    # Header container
    var header_container = VBoxContainer.new()
    header_container.position = Vector2(50, 30)
    header_container.size = Vector2(924, 100)
    add_child(header_container)
    
    # Shop title
    var title = Label.new()
    title.text = "═══ WEAPON SHOP ═══"
    title.add_theme_color_override("font_color", Color.CYAN)
    title.add_theme_font_size_override("font_size", 36)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    header_container.add_child(title)
    
    # Money display
    money_label = Label.new()
    money_label.add_theme_color_override("font_color", Color.YELLOW)
    money_label.add_theme_font_size_override("font_size", 28)
    money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    header_container.add_child(money_label)
    
    # Main content area
    var content_container = VBoxContainer.new()
    content_container.position = Vector2(50, 150)
    content_container.size = Vector2(924, 450)
    content_container.add_theme_constant_override("separation", 15)
    add_child(content_container)
    
    # Instructions
    var instructions = Label.new()
    instructions.text = "Choose weapons to enhance your tank's firepower • Green = Affordable • Red = Too Expensive"
    instructions.add_theme_color_override("font_color", Color.WHITE)
    instructions.add_theme_font_size_override("font_size", 18)
    instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content_container.add_child(instructions)
    
    # Weapons grid container
    var weapons_container = GridContainer.new()
    weapons_container.columns = 2
    weapons_container.add_theme_constant_override("h_separation", 20)
    weapons_container.add_theme_constant_override("v_separation", 15)
    content_container.add_child(weapons_container)
    
    # Store reference for weapon buttons
    self.set_meta("weapons_container", weapons_container)
    
    # Footer container
    var footer_container = HBoxContainer.new()
    footer_container.position = Vector2(50, 620)
    footer_container.size = Vector2(924, 80)
    footer_container.alignment = BoxContainer.ALIGNMENT_CENTER
    add_child(footer_container)
    
    # Close button
    var close_button = Button.new()
    close_button.text = "⚔ CONTINUE TO BATTLE ⚔"
    close_button.add_theme_font_size_override("font_size", 24)
    close_button.custom_minimum_size = Vector2(300, 60)
    close_button.pressed.connect(_on_close_pressed)
    footer_container.add_child(close_button)

func setup_available_weapons():
    available_weapons = [
        {
            "name": "Basic Missile",
            "type": Weapon.WeaponType.MISSILE,
            "damage": 15,
            "cost": 0,
            "fire_rate": 2.0,
            "speed": 400.0,
            "range": 600.0,
            "ammo": -1,
            "description": "Standard starting weapon"
        },
        {
            "name": "Heavy Missile",
            "type": Weapon.WeaponType.MISSILE,
            "damage": 25,
            "cost": 300,
            "fire_rate": 1.5,
            "speed": 350.0,
            "range": 700.0,
            "ammo": -1,
            "description": "More damage, slower fire rate"
        },
        {
            "name": "Rapid Fire",
            "type": Weapon.WeaponType.MISSILE,
            "damage": 8,
            "cost": 250,
            "fire_rate": 4.0,
            "speed": 450.0,
            "range": 500.0,
            "ammo": -1,
            "description": "Fast firing, lower damage"
        },
        {
            "name": "Laser Cannon",
            "type": Weapon.WeaponType.LASER,
            "damage": 20,
            "cost": 500,
            "fire_rate": 3.0,
            "speed": 800.0,
            "range": 800.0,
            "ammo": -1,
            "description": "High speed laser weapon"
        },
        {
            "name": "Explosive Shell",
            "type": Weapon.WeaponType.EXPLOSIVE,
            "damage": 35,
            "cost": 600,
            "fire_rate": 1.0,
            "speed": 300.0,
            "range": 600.0,
            "ammo": -1,
            "description": "Devastating but slow"
        }
    ]
    
    create_weapon_buttons()

func create_weapon_buttons():
    var weapons_container = self.get_meta("weapons_container")
    
    for i in range(available_weapons.size()):
        var weapon = available_weapons[i]
        
        # Create weapon card container
        var weapon_card = VBoxContainer.new()
        weapon_card.custom_minimum_size = Vector2(440, 120)
        weapon_card.add_theme_constant_override("separation", 5)
        
        # Weapon button
        var button = Button.new()
        button.text = "🔫 %s - $%d" % [weapon.name, weapon.cost]
        button.add_theme_font_size_override("font_size", 20)
        button.custom_minimum_size = Vector2(440, 50)
        button.pressed.connect(_on_weapon_button_pressed.bind(weapon))
        weapon_card.add_child(button)
        
        # Weapon stats
        var stats_label = Label.new()
        stats_label.text = "%s\nDamage: %d | Fire Rate: %.1f/s | Range: %d" % [
            weapon.description, weapon.damage, weapon.fire_rate, weapon.range
        ]
        stats_label.add_theme_font_size_override("font_size", 14)
        stats_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
        weapon_card.add_child(stats_label)
        
        weapons_container.add_child(weapon_card)
        weapon_buttons.append(button)
    
    update_button_colors()

func update_button_colors():
    var player_money = GameManager.player_money
    
    for i in range(weapon_buttons.size()):
        var button = weapon_buttons[i]
        var weapon = available_weapons[i]
        
        if weapon.cost <= player_money:
            button.modulate = Color.GREEN
        else:
            button.modulate = Color.RED

func update_money_display():
    if money_label:
        money_label.text = "Money: $%d" % GameManager.player_money

func _on_weapon_button_pressed(weapon_data: Dictionary):
    if weapon_data.cost <= GameManager.player_money:
        # Purchase successful
        GameManager.spend_money(weapon_data.cost)
        print("Purchased %s for $%d" % [weapon_data.name, weapon_data.cost])
        weapon_purchased.emit(weapon_data)
        update_money_display()
        update_button_colors()
    else:
        print("Not enough money for %s" % weapon_data.name)

func _on_close_pressed():
    shop_closed.emit()
    queue_free()