extends Node
class_name CollisionManager

# Collision layer constants using bit flags
enum Layer {
	TANKS = 1,        # Layer 1: bit 0
	PROJECTILES = 2,  # Layer 2: bit 1
	ENVIRONMENT = 4,  # Layer 3: bit 2
	PICKUPS = 8,      # Layer 4: bit 3
	SHIELDS = 16,     # Layer 5: bit 4
	EXPLOSIONS = 32   # Layer 6: bit 5
}

# Collision mask presets for common configurations
enum MaskPreset {
	TANK_DEFAULT,
	PROJECTILE_DEFAULT,
	EXPLOSION_DEFAULT,
	PICKUP_DEFAULT
}

func _ready():
	print("CollisionManager initialized with layer system")

# Configure collision layers and masks for different entity types
func configure_tank(body: CharacterBody2D):
	"""Configure a tank with proper collision settings"""
	body.collision_layer = Layer.TANKS
	body.collision_mask = Layer.TANKS | Layer.ENVIRONMENT | Layer.PICKUPS
	print("Configured tank collision: layer=%d, mask=%d" % [body.collision_layer, body.collision_mask])

func configure_projectile(area: Area2D):
	"""Configure a projectile with proper collision settings"""
	area.collision_layer = Layer.PROJECTILES
	area.collision_mask = Layer.TANKS | Layer.ENVIRONMENT | Layer.SHIELDS
	print("Configured projectile collision: layer=%d, mask=%d" % [area.collision_layer, area.collision_mask])

func configure_explosion(area: Area2D):
	"""Configure an explosion with proper collision settings"""
	area.collision_layer = Layer.EXPLOSIONS
	area.collision_mask = Layer.TANKS | Layer.ENVIRONMENT
	print("Configured explosion collision: layer=%d, mask=%d" % [area.collision_layer, area.collision_mask])

func configure_environment(body: StaticBody2D):
	"""Configure environment objects (walls, obstacles)"""
	body.collision_layer = Layer.ENVIRONMENT
	body.collision_mask = 0  # Environment doesn't need to detect anything
	print("Configured environment collision: layer=%d, mask=%d" % [body.collision_layer, body.collision_mask])

func configure_pickup(area: Area2D):
	"""Configure pickups (health, ammo, etc.)"""
	area.collision_layer = Layer.PICKUPS
	area.collision_mask = Layer.TANKS
	print("Configured pickup collision: layer=%d, mask=%d" % [area.collision_layer, area.collision_mask])

# Utility functions for collision debugging
func get_layer_name(layer_bit: int) -> String:
	"""Get human-readable name for collision layer"""
	match layer_bit:
		Layer.TANKS: return "TANKS"
		Layer.PROJECTILES: return "PROJECTILES"
		Layer.ENVIRONMENT: return "ENVIRONMENT"
		Layer.PICKUPS: return "PICKUPS"
		Layer.SHIELDS: return "SHIELDS"
		Layer.EXPLOSIONS: return "EXPLOSIONS"
		_: return "UNKNOWN"

func debug_collision(body: Node2D, collision_type: String = ""):
	"""Debug collision settings for any physics body"""
	var layer = 0
	var mask = 0
	
	if body.has_method("get_collision_layer"):
		layer = body.get_collision_layer()
	if body.has_method("get_collision_mask"):
		mask = body.get_collision_mask()
	
	print("DEBUG %s [%s]: Layer=%d (%s), Mask=%d" % [
		collision_type, body.name, layer, get_layer_name(layer), mask
	])

# Collision validation functions
func can_collide(layer1: int, mask1: int, layer2: int, mask2: int) -> bool:
	"""Check if two objects can collide with each other"""
	return (layer1 & mask2) != 0 or (layer2 & mask1) != 0

func validate_collision_setup():
	"""Validate that collision layers are set up correctly"""
	print("=== Collision Layer Validation ===")
	print("TANKS can hit PROJECTILES: %s" % can_collide(Layer.TANKS, Layer.TANKS | Layer.ENVIRONMENT | Layer.PICKUPS, Layer.PROJECTILES, Layer.TANKS | Layer.ENVIRONMENT | Layer.SHIELDS))
	print("PROJECTILES can hit TANKS: %s" % can_collide(Layer.PROJECTILES, Layer.TANKS | Layer.ENVIRONMENT | Layer.SHIELDS, Layer.TANKS, Layer.TANKS | Layer.ENVIRONMENT | Layer.PICKUPS))
	print("EXPLOSIONS can hit TANKS: %s" % can_collide(Layer.EXPLOSIONS, Layer.TANKS | Layer.ENVIRONMENT, Layer.TANKS, Layer.TANKS | Layer.ENVIRONMENT | Layer.PICKUPS))
	print("==================================")