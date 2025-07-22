extends Node2D

@export var explosion_color: Color = Color.ORANGE
@export var fragment_count: int = 12
@export var explosion_duration: float = 1.5
@export var explosion_radius: float = 50.0

var fragments: Array[Dictionary] = []
var explosion_timer: float = 0.0
var is_exploding: bool = false

func _ready():
    visible = false

func start_explosion(tank_color: Color):
    explosion_color = tank_color
    setup_fragments()
    is_exploding = true
    visible = true
    explosion_timer = 0.0

func setup_fragments():
    fragments.clear()
    
    for i in range(fragment_count):
        var angle = (2.0 * PI * i) / fragment_count
        var fragment = {
            "start_pos": Vector2.ZERO,
            "velocity": Vector2(cos(angle), sin(angle)) * randf_range(80, 150),
            "size": randf_range(3, 8),
            "rotation_speed": randf_range(-10, 10),
            "rotation": 0.0,
            "color": explosion_color,
            "life": randf_range(0.8, 1.2)
        }
        fragments.append(fragment)

func _process(delta):
    if not is_exploding:
        return
    
    explosion_timer += delta
    
    # Update fragments
    for fragment in fragments:
        fragment.start_pos += fragment.velocity * delta
        fragment.rotation += fragment.rotation_speed * delta
        fragment.velocity *= 0.95  # Friction
        
        # Fade out over time
        var life_pct = 1.0 - (explosion_timer / explosion_duration)
        fragment.color.a = life_pct
    
    queue_redraw()
    
    # End explosion
    if explosion_timer >= explosion_duration:
        is_exploding = false
        visible = false
        queue_free()

func _draw():
    if not is_exploding:
        return
    
    # Draw central flash
    var flash_radius = explosion_radius * (1.0 - explosion_timer / explosion_duration)
    var flash_alpha = 1.0 - (explosion_timer / explosion_duration)
    draw_circle(Vector2.ZERO, flash_radius, Color(1, 1, 0.5, flash_alpha * 0.3))
    
    # Draw fragments
    for fragment in fragments:
        var points = PackedVector2Array()
        var size = fragment.size
        
        # Create triangular fragment
        points.append(fragment.start_pos + Vector2(size, 0).rotated(fragment.rotation))
        points.append(fragment.start_pos + Vector2(-size/2, size/2).rotated(fragment.rotation))
        points.append(fragment.start_pos + Vector2(-size/2, -size/2).rotated(fragment.rotation))
        
        draw_colored_polygon(points, fragment.color)
        draw_polyline(points + PackedVector2Array([points[0]]), Color.WHITE, 1.0)