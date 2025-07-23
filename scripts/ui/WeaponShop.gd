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
    # Dark background
    var background = ColorRect.new()
    background.color = Color(0.1, 0.1, 0.2, 0.9)
    background.size = get_viewport().size
    add_child(background)
    
    # Shop title
    var title = Label.new()
    title.text = "WEAPON SHOP"
    title.position = Vector2(400, 50)
    title.add_theme_color_override("font_color", Color.WHITE)
    title.add_theme_font_size_override("font_size", 32)
    add_child(title)
    
    # Money display
    money_label = Label.new()
    money_label.position = Vector2(50, 100)
    money_label.add_theme_color_override("font_color", Color.YELLOW)
    money_label.add_theme_font_size_override("font_size", 24)
    add_child(money_label)
    
    # Close button
    var close_button = Button.new()
    close_button.text = "Continue to Battle"
    close_button.position = Vector2(700, 600)
    close_button.size = Vector2(200, 50)
    close_button.pressed.connect(_on_close_pressed)
    add_child(close_button)
    
    # Instructions
    var instructions = Label.new()
    instructions.text = "Click on weapons to purchase. Green = affordable, Red = too expensive"
    instructions.position = Vector2(50, 650)
    instructions.add_theme_color_override("font_color", Color.WHITE)
    add_child(instructions)

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
    for i in range(available_weapons.size()):
        var weapon = available_weapons[i]
        var button = Button.new()
        
        button.text = "%s - $%d\n%s\nDamage: %d | Rate: %.1f | Range: %d" % [
            weapon.name, weapon.cost, weapon.description, 
            weapon.damage, weapon.fire_rate, weapon.range
        ]
        
        button.position = Vector2(50 + (i % 3) * 300, 150 + (i / 3) * 120)
        button.size = Vector2(280, 100)
        button.pressed.connect(_on_weapon_button_pressed.bind(weapon))
        
        add_child(button)
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