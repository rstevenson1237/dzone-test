extends Node2D

@export var radius: float = 3.0
@export var color: Color = Color.YELLOW
@export var trail_length: int = 5

var trail_points: Array[Vector2] = []

func _ready():
    # Initialize trail
    for i in range(trail_length):
        trail_points.append(global_position)

func _process(delta):
    # Update trail
    trail_points.push_front(global_position)
    if trail_points.size() > trail_length:
        trail_points.pop_back()
    queue_redraw()

func _draw():
    # Draw trail
    if trail_points.size() > 1:
        for i in range(trail_points.size() - 1):
            var alpha = float(trail_length - i) / float(trail_length) * 0.5
            var trail_color = Color(color.r, color.g, color.b, alpha)
            var point1 = to_local(trail_points[i])
            var point2 = to_local(trail_points[i + 1])
            draw_line(point1, point2, trail_color, 2.0)
    
    # Draw projectile body
    draw_circle(Vector2.ZERO, radius, color)
    draw_circle(Vector2.ZERO, radius, Color.WHITE, false, 1.0)