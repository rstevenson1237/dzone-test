extends Node2D

@export var tank_color: Color = Color.GREEN
@export var size: float = 16.0

var tank_points: PackedVector2Array
var cylinder_positions: Array[Vector2]

func _ready():
    setup_tank_geometry()

func setup_tank_geometry():
    # Triangular tank pointing upward (forward direction)
    var half_size = size * 0.5
    tank_points = PackedVector2Array([
        Vector2(0, -half_size),        # Top point (front)
        Vector2(-half_size, half_size), # Bottom left
        Vector2(half_size, half_size)   # Bottom right
    ])
    
    # Three cylinder positions (D-Zone style)
    var cylinder_offset = size * 0.3
    cylinder_positions = [
        Vector2(-cylinder_offset * 0.5, cylinder_offset * 0.3),  # Left cylinder
        Vector2(cylinder_offset * 0.5, cylinder_offset * 0.3),   # Right cylinder  
        Vector2(0, -cylinder_offset * 0.2)                       # Front cylinder
    ]

func _draw():
    # Draw main tank body (triangle)
    draw_colored_polygon(tank_points, tank_color)
    
    # Draw tank outline
    draw_polyline(tank_points + PackedVector2Array([tank_points[0]]), Color.WHITE, 1.5)
    
    # Draw three cylinders (D-Zone style)
    var cylinder_color = tank_color.darkened(0.3)
    var cylinder_radius = size * 0.12
    
    for pos in cylinder_positions:
        draw_circle(pos, cylinder_radius, cylinder_color)
        draw_circle(pos, cylinder_radius, Color.WHITE, false, 1.0)
    
    # Draw direction indicator (small line at front)
    var front_indicator = Vector2(0, -size * 0.6)
    draw_line(front_indicator, front_indicator + Vector2(0, -4), Color.WHITE, 2.0)

func set_tank_color(color: Color):
    tank_color = color
    queue_redraw()

func set_health_percentage(health_pct: float):
    # Color shift and fade based on health
    if health_pct > 0.7:
        # Healthy - normal color
        tank_color.a = 1.0
    elif health_pct > 0.3:
        # Damaged - slightly faded with red tint
        tank_color = tank_color.lerp(Color.RED, 0.3)
        tank_color.a = 0.9
    else:
        # Critical - more red and faded
        tank_color = tank_color.lerp(Color.RED, 0.6)
        tank_color.a = 0.7
    
    queue_redraw()

func flash_damage():
    # Visual damage flash effect
    var original_color = tank_color
    tank_color = Color.WHITE
    queue_redraw()
    
    # Return to normal after brief flash
    var tween = create_tween()
    tween.tween_method(func(color): tank_color = color; queue_redraw(), Color.WHITE, original_color, 0.2)