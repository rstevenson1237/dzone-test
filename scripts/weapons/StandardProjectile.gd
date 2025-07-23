extends BaseProjectile
class_name StandardProjectile

func setup_visual():
	"""Set up standard projectile visual"""
	visual_node = Node2D.new()
	visual_node.set_script(preload("res://scripts/weapons/ProjectileVisual.gd"))
	add_child(visual_node)

func get_collision_radius() -> float:
	"""Standard projectile collision radius"""
	return 3.0