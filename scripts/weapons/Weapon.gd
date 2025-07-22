extends Node2D
class_name Weapon

signal weapon_fired(projectile: Projectile)

enum WeaponType {
    MISSILE,
    LASER,
    EXPLOSIVE,
    DEFENSIVE,
    SPECIAL
}

@export var weapon_name: String = "Basic Weapon"
@export var weapon_type: WeaponType = WeaponType.MISSILE
@export var damage: int = 10
@export var cost: int = 100
@export var fire_rate: float = 1.0
@export var projectile_speed: float = 300.0
@export var projectile_range: float = 500.0
@export var ammo_count: int = -1

var last_fire_time: float = 0.0
var owner_tank: Tank

func _ready():
    print("Weapon '%s' initialized" % weapon_name)

func can_fire() -> bool:
    var current_time = Time.get_time_dict_from_system()
    var current_timestamp = current_time.hour * 3600 + current_time.minute * 60 + current_time.second
    var time_since_last_fire = current_timestamp - last_fire_time
    
    if ammo_count == 0:
        return false
    
    return time_since_last_fire >= (1.0 / fire_rate)

func fire(start_position: Vector2, direction: Vector2) -> Projectile:
    if not can_fire():
        return null
    
    var projectile = create_projectile(start_position, direction)
    if projectile:
        var current_time = Time.get_time_dict_from_system()
        last_fire_time = current_time.hour * 3600 + current_time.minute * 60 + current_time.second
        
        if ammo_count > 0:
            ammo_count -= 1
        
        weapon_fired.emit(projectile)
        get_tree().current_scene.add_child(projectile)
    
    return projectile

func create_projectile(start_position: Vector2, direction: Vector2) -> Projectile:
    var projectile = preload("res://scripts/weapons/Projectile.gd").new()
    projectile.setup(start_position, direction, damage, projectile_speed, projectile_range, owner_tank)
    return projectile

func get_weapon_info() -> Dictionary:
    return {
        "name": weapon_name,
        "type": weapon_type,
        "damage": damage,
        "cost": cost,
        "fire_rate": fire_rate,
        "ammo": ammo_count
    }
