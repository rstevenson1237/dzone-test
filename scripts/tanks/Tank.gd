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
var tank_visual: Node2D

func _ready():
    input_manager = GameManager.input_manager
    setup_collision()
    setup_tank_visual()
    setup_weapon_manager()
    print("Tank initialized for player %d" % (player_id + 1))

func setup_collision():
    """Configure tank collision using collision manager"""
    if GameManager and GameManager.collision_manager:
        GameManager.collision_manager.configure_tank(self)
        GameManager.collision_manager.debug_collision(self, "TANK")
        print("Tank %d collision configured: layer=%d, mask=%d" % [player_id + 1, collision_layer, collision_mask])
        
        # Ensure collision layer is properly set for Area2D detection
        set_collision_layer(collision_layer)
        set_collision_mask(collision_mask)
        print("🏷️  Tank %d layer/mask explicitly set: layer=%d, mask=%d" % [player_id + 1, get_collision_layer(), get_collision_mask()])
        
        # Validate that tank can be detected by projectiles
        var projectile_mask = 1 | 4 | 16  # TANKS | ENVIRONMENT | SHIELDS
        var can_be_hit = (get_collision_layer() & projectile_mask) != 0
        print("🎯 Tank %d can be hit by projectiles: %s (layer=%d, projectile_mask=%d)" % [player_id + 1, can_be_hit, get_collision_layer(), projectile_mask])
    else:
        print("WARNING: Tank %d - No collision manager available!" % (player_id + 1))

func setup_tank_visual():
    tank_visual = Node2D.new()
    tank_visual.set_script(preload("res://scripts/tanks/TankVisual.gd"))
    add_child(tank_visual)
    
    # Set player-specific color
    var player_colors = [Color.GREEN, Color.BLUE, Color.RED, Color.YELLOW, Color.MAGENTA, Color.CYAN]
    if player_id < player_colors.size():
        tank_visual.set_tank_color(player_colors[player_id])

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
    
    var forward_input = input_manager.get_forward_movement(player_id)
    var rotation_input = input_manager.get_rotation_input(player_id)
    var fire_input = input_manager.get_fire_input(player_id)
    var special_input = input_manager.is_action_just_pressed("special", player_id)
    
    if rotation_input != 0:
        rotation += rotation_input * rotation_speed * delta
    
    if forward_input != 0:
        # Move only in the direction the tank is facing
        var forward_direction = Vector2.UP.rotated(rotation)
        var target_velocity = forward_direction * forward_input * max_speed
        velocity = velocity.move_toward(target_velocity, acceleration * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
    
    if fire_input and weapon_manager:
        var fire_direction = Vector2.UP.rotated(rotation)
        var fire_position = global_position + fire_direction * 20
        weapon_manager.fire_current_weapon(fire_position, fire_direction)
    
    if special_input and weapon_manager:
        weapon_manager.cycle_weapons()
        print("Player %d cycled weapons" % (player_id + 1))

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
    print("💔 Tank %d took %d damage, health: %d/%d" % [player_id + 1, damage, current_health, max_health])
    
    if tank_visual:
        tank_visual.flash_damage()
        tank_visual.set_health_percentage(get_health_percentage())
        print("   🎨 Visual feedback applied")
    else:
        print("   ⚠️  No tank visual for feedback")
    
    if current_health <= 0:
        print("💀 Tank %d health depleted - destroying!" % (player_id + 1))
        destroy_tank()

func destroy_tank():
    print("Tank %d destroyed!" % (player_id + 1))
    
    # Create explosion effect
    var explosion = preload("res://scripts/effects/ExplosionEffect.gd").new()
    get_parent().add_child(explosion)
    explosion.global_position = global_position
    explosion.start_explosion(tank_visual.tank_color if tank_visual else Color.GREEN)
    
    tank_destroyed.emit(self)
    queue_free()

func get_health_percentage() -> float:
    return float(current_health) / float(max_health)
