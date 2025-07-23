extends Node
class_name WeaponManager

signal weapon_added(weapon: Weapon)
signal weapon_removed(weapon: Weapon)

@export var max_weapons: int = 7
var equipped_weapons: Array[Weapon] = []
var owner_tank: Tank

func _ready():
    print("WeaponManager initialized")

func setup(tank: Tank):
    owner_tank = tank
    
    var basic_weapon = create_basic_weapon()
    add_weapon(basic_weapon)

func create_basic_weapon() -> Weapon:
    var weapon_data = {
        "name": "Basic Missile",
        "type": Weapon.WeaponType.MISSILE,
        "damage": 15,
        "cost": 0,
        "fire_rate": 2.0,
        "speed": 400.0,
        "range": 600.0,
        "ammo": -1
    }
    return create_weapon_from_data(weapon_data)

func create_weapon_from_data(weapon_data: Dictionary) -> Weapon:
    var weapon = Weapon.new()
    weapon.weapon_name = weapon_data.name
    weapon.weapon_type = weapon_data.type
    weapon.damage = weapon_data.damage
    weapon.cost = weapon_data.cost
    weapon.fire_rate = weapon_data.fire_rate
    weapon.projectile_speed = weapon_data.speed
    weapon.projectile_range = weapon_data.range
    weapon.ammo_count = weapon_data.ammo
    weapon.owner_tank = owner_tank
    return weapon

func add_weapon(weapon: Weapon) -> bool:
    if equipped_weapons.size() >= max_weapons:
        return false
    
    equipped_weapons.append(weapon)
    add_child(weapon)
    weapon.owner_tank = owner_tank
    weapon_added.emit(weapon)
    return true

func remove_weapon(weapon: Weapon) -> bool:
    var index = equipped_weapons.find(weapon)
    if index == -1:
        return false
    
    equipped_weapons.remove_at(index)
    remove_child(weapon)
    weapon_removed.emit(weapon)
    return true

func fire_weapon(weapon_index: int, start_position: Vector2, direction: Vector2) -> BaseProjectile:
    if weapon_index < 0 or weapon_index >= equipped_weapons.size():
        return null
    
    var weapon = equipped_weapons[weapon_index]
    return weapon.fire(start_position, direction)

func fire_primary_weapon(start_position: Vector2, direction: Vector2) -> BaseProjectile:
    return fire_weapon(0, start_position, direction)

func get_weapon_count() -> int:
    return equipped_weapons.size()

func get_weapon(index: int) -> Weapon:
    if index < 0 or index >= equipped_weapons.size():
        return null
    return equipped_weapons[index]

func get_all_weapons() -> Array[Weapon]:
    return equipped_weapons

var current_weapon_index: int = 0

func cycle_weapons():
    if equipped_weapons.size() > 1:
        current_weapon_index = (current_weapon_index + 1) % equipped_weapons.size()
        print("Switched to weapon: %s" % equipped_weapons[current_weapon_index].weapon_name)

func fire_current_weapon(start_position: Vector2, direction: Vector2) -> BaseProjectile:
    return fire_weapon(current_weapon_index, start_position, direction)
