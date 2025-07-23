extends BaseProjectile
class_name LaserProjectileNew

func setup_visual():
	"""Set up laser projectile visual"""
	visual_node = Node2D.new()
	visual_node.set_script(preload("res://scripts/weapons/LaserVisual.gd"))
	add_child(visual_node)

func get_collision_radius() -> float:
	"""Laser projectile has smaller collision radius"""
	return 2.0