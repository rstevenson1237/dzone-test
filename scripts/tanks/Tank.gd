extends CharacterBody2D
class_name Tank

signal tank_destroyed(tank: Tank)

@export var player_id: int = 0
@export var max_speed: float = 200.0
@export var acceleration: float = 500.0
@export var friction: float = 300.0
@export var rotation_speed: float = 3.0

var input_manager: InputManager
var current_health: int = 100
var max_health: int = 100
var weapon_manager: WeaponManager

func _ready():
    input_manager = GameManager.input_manager
    setup_weapon_manager()
    print("Tank initialized for player %d" % (player_id + 1))

func setup_weapon_manager():
    weapon_manager = WeaponManager.new()
    add_child(weapon_manager)
    weapon_manager.setup(self)

func _physics_process(delta):
    handle_input(delta)
    apply_movement(delta)
    check_boundaries()

func handle_input(delta):
    if not input_manager:
        return
    
    var movement_input = input_manager.get_movement_vector(player_id)
    var rotation_input = input_manager.get_rotation_input(player_id)
    var fire_input = input_manager.get_fire_input(player_id)
    
    if rotation_input != 0:
        rotation += rotation_input * rotation_speed * delta
    
    if movement_input.length() > 0:
        var target_velocity = movement_input * max_speed
        velocity = velocity.move_toward(target_velocity, acceleration * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
    
    if fire_input and weapon_manager:
        var fire_direction = Vector2.UP.rotated(rotation)
        var fire_position = global_position + fire_direction * 20
        weapon_manager.fire_primary_weapon(fire_position, fire_direction)

func apply_movement(delta):
    move_and_slide()

func check_boundaries():
    var viewport_size = get_viewport().size
    var margin = 16
    
    if global_position.x < margin:
        global_position.x = margin
        velocity.x = 0
    elif global_position.x > viewport_size.x - margin:
        global_position.x = viewport_size.x - margin
        velocity.x = 0
    
    if global_position.y < margin:
        global_position.y = margin
        velocity.y = 0
    elif global_position.y > viewport_size.y - margin:
        global_position.y = viewport_size.y - margin
        velocity.y = 0

func take_damage(damage: int):
    current_health -= damage
    if current_health <= 0:
        destroy_tank()

func destroy_tank():
    tank_destroyed.emit(self)
    queue_free()

func get_health_percentage() -> float:
    return float(current_health) / float(max_health)
