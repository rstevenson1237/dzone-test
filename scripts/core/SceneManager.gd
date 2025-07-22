extends Node
class_name SceneManager

signal scene_changing(scene_path: String)
signal scene_changed(scene_path: String)

var current_scene: Node
var is_changing: bool = false

func _ready():
    current_scene = get_tree().current_scene
    print("SceneManager initialized with current scene: %s" % current_scene.scene_file_path)

func change_scene(scene_path: String) -> void:
    if is_changing:
        print("Scene change already in progress, ignoring request")
        return
    
    is_changing = true
    scene_changing.emit(scene_path)
    print("Changing scene to: %s" % scene_path)
    
    await fade_out()
    
    var error = get_tree().change_scene_to_file(scene_path)
    if error != OK:
        print("Failed to change scene: %s" % error)
        is_changing = false
        return
    
    await fade_in()
    
    current_scene = get_tree().current_scene
    is_changing = false
    scene_changed.emit(scene_path)
    print("Scene changed successfully to: %s" % scene_path)

func change_scene_to_packed(scene: PackedScene) -> void:
    if is_changing:
        print("Scene change already in progress, ignoring request")
        return
    
    is_changing = true
    scene_changing.emit("packed_scene")
    
    await fade_out()
    
    get_tree().change_scene_to_packed(scene)
    
    await fade_in()
    
    current_scene = get_tree().current_scene
    is_changing = false
    scene_changed.emit("packed_scene")

func reload_current_scene() -> void:
    if current_scene and current_scene.scene_file_path:
        change_scene(current_scene.scene_file_path)

func goto_main_menu() -> void:
    change_scene("res://scenes/menus/MainMenu.tscn")

func goto_arena() -> void:
    change_scene("res://scenes/arena/Arena.tscn")

func goto_shop() -> void:
    change_scene("res://scenes/ui/ShopMenu.tscn")

func fade_out() -> void:
    var tween = create_tween()
    var overlay = create_fade_overlay()
    get_tree().root.add_child(overlay)
    
    overlay.modulate.a = 0.0
    tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
    await tween.finished

func fade_in() -> void:
    await get_tree().process_frame
    var overlay = get_fade_overlay()
    if overlay:
        var tween = create_tween()
        tween.tween_property(overlay, "modulate:a", 0.0, 0.3)
        await tween.finished
        overlay.queue_free()

func create_fade_overlay() -> ColorRect:
    var overlay = ColorRect.new()
    overlay.name = "SceneTransitionOverlay"
    overlay.color = Color.BLACK
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 100
    return overlay

func get_fade_overlay() -> ColorRect:
    return get_tree().root.get_node_or_null("SceneTransitionOverlay")
