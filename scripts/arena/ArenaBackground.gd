extends Control

@export var grid_color: Color = Color(0.3, 0.3, 0.5, 0.3)
@export var border_color: Color = Color(0.5, 0.5, 0.8, 1.0)
@export var grid_size: int = 50

func _draw():
    var rect = get_rect()
    
    # Draw dark space background
    draw_rect(rect, Color(0.05, 0.05, 0.15, 1.0))
    
    # Draw grid pattern for space station feel
    draw_grid_pattern(rect)
    
    # Draw border
    draw_border(rect)

func draw_grid_pattern(rect: Rect2):
    # Vertical lines
    for x in range(0, int(rect.size.x), grid_size):
        draw_line(Vector2(x, 0), Vector2(x, rect.size.y), grid_color, 1.0)
    
    # Horizontal lines  
    for y in range(0, int(rect.size.y), grid_size):
        draw_line(Vector2(0, y), Vector2(rect.size.x, y), grid_color, 1.0)

func draw_border(rect: Rect2):
    var border_width = 4.0
    var points = PackedVector2Array([
        Vector2(0, 0),
        Vector2(rect.size.x, 0),
        Vector2(rect.size.x, rect.size.y),
        Vector2(0, rect.size.y),
        Vector2(0, 0)
    ])
    
    draw_polyline(points, border_color, border_width)