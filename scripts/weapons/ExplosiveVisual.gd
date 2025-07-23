extends Node2D

@export var radius: float = 4.0
@export var color: Color = Color.ORANGE

var pulse_time: float = 0.0

func _ready():
    set_process(true)

func _process(delta):
    pulse_time += delta * 5.0
    queue_redraw()

func _draw():
    var pulse_factor = (sin(pulse_time) + 1.0) * 0.5
    var current_radius = radius + pulse_factor * 2.0
    
    # Main body
    draw_circle(Vector2.ZERO, current_radius, color)
    # Bright core
    draw_circle(Vector2.ZERO, current_radius * 0.6, Color.YELLOW)
    # Warning pulse
    draw_circle(Vector2.ZERO, current_radius, Color.RED, false, 2.0)