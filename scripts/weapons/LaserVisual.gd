extends Node2D

@export var length: float = 8.0
@export var width: float = 2.0
@export var color: Color = Color.CYAN

func _draw():
    # Draw laser beam as a bright line
    var start = Vector2(-length/2, 0)
    var end = Vector2(length/2, 0)
    
    # Main beam
    draw_line(start, end, color, width)
    # Bright core
    draw_line(start, end, Color.WHITE, width * 0.5)
    
    # Glow effect
    for i in range(3):
        var glow_width = width + i * 2
        var glow_color = Color(color.r, color.g, color.b, 0.3 - i * 0.1)
        draw_line(start, end, glow_color, glow_width)