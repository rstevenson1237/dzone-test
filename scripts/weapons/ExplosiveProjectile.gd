extends RigidBody2D
class_name ExplosiveProjectile

signal projectile_hit(target: Node2D, damage: int)
signal projectile_expired()

@export var damage: int = 35
@export var speed: float = 300.0
@export var max_range: float = 600.0
@export var explosion_radius: float = 60.0

var direction: Vector2
var start_position: Vector2
var distance_traveled: float = 0.0
var owner_tank: Tank
var detection_area: Area2D

func _ready():
    gravity_scale = 0.0
    
    # Create collision shape for physics
    var collision_shape = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = 4.0  # Slightly larger than regular projectiles
    collision_shape.shape = shape
    add_child(collision_shape)
    
    # Create Area2D for better collision detection with CharacterBody2D
    detection_area = Area2D.new()
    var area_collision = CollisionShape2D.new()
    var area_shape = CircleShape2D.new()
    area_shape.radius = 6.0  # Larger detection radius for explosives
    area_collision.shape = area_shape
    detection_area.add_child(area_collision)
    add_child(detection_area)
    
    # Connect area signals for detecting tanks
    detection_area.body_entered.connect(_on_detection_area_entered)
    
    var visual = Node2D.new()
    visual.set_script(preload("res://scripts/weapons/ExplosiveVisual.gd"))
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
        explode()

func _on_detection_area_entered(body: Node2D):
    if body == owner_tank:
        return
    
    print("Explosive projectile detected collision with: %s" % body.name)
    explode()

func explode():
    # Create explosion effect
    var explosion = preload("res://scripts/effects/ExplosionEffect.gd").new()
    get_parent().add_child(explosion)
    explosion.global_position = global_position
    explosion.explosion_radius = explosion_radius
    explosion.start_explosion(Color.ORANGE)
    
    # Damage all tanks in explosion radius
    damage_in_radius()
    
    projectile_expired.emit()
    queue_free()

func damage_in_radius():
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()
    var shape = CircleShape2D.new()
    shape.radius = explosion_radius
    query.shape = shape
    query.transform = Transform2D(0, global_position)
    
    var results = space_state.intersect_shape(query)
    
    for result in results:
        var body = result.collider
        if body != owner_tank and body.has_method("take_damage"):
            var distance = global_position.distance_to(body.global_position)
            var damage_factor = 1.0 - (distance / explosion_radius)
            var final_damage = int(damage * damage_factor)
            body.take_damage(final_damage)
            projectile_hit.emit(body, final_damage)

func _on_timer_timeout():
    explode()