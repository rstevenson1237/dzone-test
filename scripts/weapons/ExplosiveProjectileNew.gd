extends BaseProjectile
class_name ExplosiveProjectileNew

@export var explosion_radius: float = 60.0

func setup_visual():
	"""Set up explosive projectile visual"""
	visual_node = Node2D.new()
	visual_node.set_script(preload("res://scripts/weapons/ExplosiveVisual.gd"))
	add_child(visual_node)

func get_collision_radius() -> float:
	"""Explosive projectile has larger collision radius"""
	return 4.0

func on_collision(target: Node2D):
	"""Create explosion on collision"""
	explode()

func explode():
	"""Create explosion effect and damage nearby targets"""
	print("Explosive projectile exploding at: %s" % global_position)
	
	# Create explosion visual effect
	var explosion = preload("res://scripts/effects/ExplosionEffect.gd").new()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.explosion_radius = explosion_radius
	explosion.start_explosion(Color.ORANGE)
	
	# Damage all targets in explosion radius
	damage_in_radius()

func damage_in_radius():
	"""Apply damage to all valid targets in explosion radius"""
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = explosion_radius
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.collision_mask = GameManager.collision_manager.Layer.TANKS
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var body = result.collider
		if body == owner_tank:
			continue
			
		if body.has_method("take_damage"):
			# Calculate damage based on distance (optional)
			var distance = global_position.distance_to(body.global_position)
			var damage_multiplier = 1.0 - (distance / explosion_radius)
			var final_damage = int(damage * damage_multiplier)
			
			body.take_damage(final_damage)
			print("Explosion damaged %s for %d damage" % [body.name, final_damage])