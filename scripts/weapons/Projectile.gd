extends RigidBody2D
class_name Projectile

signal projectile_hit(target: Node2D, damage: int)
signal projectile_expired()

@export var damage: int = 10
@export var speed: float = 300.0
@export var max_range: float = 500.0

var direction: Vector2
var start_position: Vector2
var distance_traveled: float = 0.0
var owner_tank: Tank
var detection_area: Area2D

func _ready():
    # Disable gravity for authentic D-Zone projectile physics
    gravity_scale = 0.0
    
    # Create collision shape for physics
    var collision_shape = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 3.0
    collision_shape.shape = shape
    add_child(collision_shape)
    
    # Create Area2D for better collision detection with CharacterBody2D
    detection_area = Area2D.new()
    var area_collision = CollisionShape2D.new()
    var area_shape = CircleShape2D.new()
    area_shape.radius = 5.0  # Slightly larger detection radius
    area_collision.shape = area_shape
    detection_area.add_child(area_collision)
    add_child(detection_area)
    
    # Connect area signals for detecting tanks
    detection_area.body_entered.connect(_on_detection_area_entered)
    
    var visual = Node2D.new()
    visual.set_script(preload("res://scripts/weapons/ProjectileVisual.gd"))
    add_child(visual)

func setup(start_pos: Vector2, dir: Vector2, proj_damage: int, proj_speed: float, proj_range: float, tank: Tank):
    start_position = start_pos
    global_position = start_pos
    direction = dir.normalized()
    damage = proj_damage
    speed = proj_speed
    max_range = proj_range
    owner_tank = tank
    
    linear_velocity = direction * speed
    
    var timer = Timer.new()
    timer.wait_time = max_range / speed
    timer.one_shot = true
    timer.timeout.connect(_on_timer_timeout)
    add_child(timer)
    timer.start()

func _physics_process(delta):
    distance_traveled += speed * delta
    
    if distance_traveled >= max_range:
        expire()

func _on_detection_area_entered(body: Node2D):
    if body == owner_tank:
        return
    
    print("Projectile detected collision with: %s" % body.name)
    
    if body.has_method("take_damage"):
        body.take_damage(damage)
        projectile_hit.emit(body, damage)
        print("Applied %d damage to %s" % [damage, body.name])
    
    expire()

func _on_timer_timeout():
    expire()

func expire():
    projectile_expired.emit()
    queue_free()