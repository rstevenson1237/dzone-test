extends Area2D
class_name BaseProjectile

signal projectile_hit(target: Node2D, damage: int)
signal projectile_expired()

@export var damage: int = 10
@export var speed: float = 300.0
@export var max_range: float = 500.0

var direction: Vector2
var start_position: Vector2
var distance_traveled: float = 0.0
var owner_tank: Tank
var collision_enabled: bool = false
var visual_node: Node2D

func _ready():
	setup_collision()
	setup_visual()
	setup_timer_expiration()

func setup_collision():
	"""Set up collision detection using collision manager"""
	if GameManager and GameManager.collision_manager:
		GameManager.collision_manager.configure_projectile(self)
		print("Collision manager configured projectile")
	else:
		print("WARNING: No collision manager available!")
	
	# Ensure collision layer and mask are properly set
	set_collision_layer(collision_layer)
	set_collision_mask(collision_mask)
	print("Projectile layer/mask explicitly set: layer=%d, mask=%d" % [get_collision_layer(), get_collision_mask()])
	
	# Create collision shape
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = get_collision_radius()
	collision_shape.shape = shape
	add_child(collision_shape)
	print("Projectile collision shape created: radius=%.1f" % get_collision_radius())
	
	# Connect collision signals
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		print("✅ body_entered signal connected")
	else:
		print("⚠️  body_entered signal was already connected")
		
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
		print("✅ area_entered signal connected")
	else:
		print("⚠️  area_entered signal was already connected")
	
	# Verify signal connections
	print("🔗 Signal verification: body_entered=%s, area_entered=%s" % [
		body_entered.is_connected(_on_body_entered), 
		area_entered.is_connected(_on_area_entered)
	])
	
	# Disable collision initially to prevent self-collision
	monitoring = false
	monitorable = true  # Allow detection by other Area2D nodes
	print("Projectile monitoring initially disabled, monitorable enabled")
	
	# Debug collision setup
	print("BaseProjectile collision setup: layer=%d, mask=%d, monitoring=%s, monitorable=%s" % [collision_layer, collision_mask, monitoring, monitorable])

func setup_visual():
	"""Set up visual representation - override in subclasses"""
	visual_node = Node2D.new()
	visual_node.set_script(preload("res://scripts/weapons/ProjectileVisual.gd"))
	add_child(visual_node)

func setup_timer_expiration():
	"""Set up automatic expiration timer"""
	var timer = Timer.new()
	timer.wait_time = max_range / speed if speed > 0 else 10.0
	timer.one_shot = true
	timer.timeout.connect(expire)
	add_child(timer)
	timer.start()

func setup(start_pos: Vector2, dir: Vector2, proj_damage: int, proj_speed: float, proj_range: float, tank: Tank):
	"""Initialize projectile with parameters"""
	start_position = start_pos
	global_position = start_pos
	direction = dir.normalized()
	damage = proj_damage
	speed = proj_speed
	max_range = proj_range
	owner_tank = tank
	
	# Enable collision after short delay to clear owner tank
	enable_collision_after_delay(0.1)
	
	print("BaseProjectile setup: damage=%d, speed=%.1f, range=%.1f" % [damage, speed, max_range])

func enable_collision_after_delay(delay: float):
	"""Enable collision detection after specified delay"""
	var enable_timer = Timer.new()
	enable_timer.wait_time = delay
	enable_timer.one_shot = true
	enable_timer.timeout.connect(_enable_collision)
	add_child(enable_timer)
	enable_timer.start()

func _enable_collision():
	"""Enable collision detection"""
	monitoring = true
	collision_enabled = true
	print("🔥 Projectile collision ENABLED: layer=%d, mask=%d, monitoring=%s, monitorable=%s at position=%s" % [collision_layer, collision_mask, monitoring, monitorable, global_position])
	
	# Debug what this projectile can potentially collide with
	var tank_layer = 1  # TANKS layer
	var can_hit_tanks = (collision_mask & tank_layer) != 0
	print("🎯 Can hit tanks (mask & layer 1): %s (mask=%d)" % [can_hit_tanks, collision_mask])

func _physics_process(delta):
	"""Update projectile position and check range"""
	# Manual position update for precise control
	global_position += direction * speed * delta
	distance_traveled += speed * delta
	
	# Debug: Check if there are any overlapping bodies (for debugging only)
	if collision_enabled and monitoring:
		var overlapping_bodies = get_overlapping_bodies()
		var overlapping_areas = get_overlapping_areas()
		if overlapping_bodies.size() > 0 or overlapping_areas.size() > 0:
			print("🔍 Projectile at %s overlapping with %d bodies, %d areas" % [global_position, overlapping_bodies.size(), overlapping_areas.size()])
			for body in overlapping_bodies:
				print("  - Body: %s (class: %s)" % [body.name, body.get_class()])
			for area in overlapping_areas:
				print("  - Area: %s (class: %s)" % [area.name, area.get_class()])
	
	# Check if projectile has exceeded range
	if distance_traveled >= max_range:
		expire()

func get_collision_radius() -> float:
	"""Get collision radius - override in subclasses for different sizes"""
	return 3.0

func _on_body_entered(body: Node2D):
	"""Handle collision with physics bodies"""
	handle_collision(body)

func _on_area_entered(area: Area2D):
	"""Handle collision with other areas"""
	handle_collision(area)

func handle_collision(target: Node2D):
	"""Process collision with any target"""
	print("💥 COLLISION DETECTED with %s (enabled=%s, target_class=%s)" % [target.name, collision_enabled, target.get_class()])
	
	if not collision_enabled:
		print("   ❌ Collision ignored - detection not enabled yet")
		return
		
	if target == owner_tank:
		print("   ❌ Ignoring collision with owner tank: %s" % target.name)
		return
	
	print("   ✅ PROCESSING COLLISION with: %s (class: %s)" % [target.name, target.get_class()])
	
	# Check target's collision layer for debugging
	if target.has_method("get_collision_layer"):
		var target_layer = target.get_collision_layer()
		print("   🏷️  Target collision layer: %d" % target_layer)
	
	# Apply damage if target can take it
	if target.has_method("take_damage"):
		target.take_damage(damage)
		projectile_hit.emit(target, damage)
		print("   ✅ Applied %d damage to %s" % [damage, target.name])
	else:
		print("   ❌ Target %s cannot take damage (no take_damage method)" % target.name)
	
	# Handle special collision effects (override in subclasses)
	on_collision(target)
	
	expire()

func on_collision(target: Node2D):
	"""Override in subclasses for special collision behavior"""
	pass

func expire():
	"""Clean up and remove projectile"""
	print("Projectile expired")
	projectile_expired.emit()
	queue_free()