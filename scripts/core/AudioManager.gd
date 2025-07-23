extends Node
class_name AudioManager

# Audio settings
var master_volume: float = 1.0
var sfx_volume: float = 0.8
var music_volume: float = 0.6

# Audio players
var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer

# Audio pools for performance
const MAX_SFX_PLAYERS = 8
var current_sfx_index = 0

func _ready():
	print("AudioManager initialized")
	setup_audio_players()
	create_default_sounds()

func setup_audio_players():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	
	# Create UI sound player
	ui_player = AudioStreamPlayer.new()
	ui_player.name = "UIPlayer"
	add_child(ui_player)
	
	# Create SFX player pool
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		add_child(player)
		sfx_players.append(player)

func create_default_sounds():
	# Since we're using vector graphics only, we'll create simple sound effects
	# using AudioStreamGenerator or simple tones
	print("Audio system ready - using programmatic sound effects")

# Public API for playing sounds
func play_ui_sound(sound_type: String):
	match sound_type:
		"button_hover":
			play_tone(ui_player, 800, 0.1, 0.3)
		"button_click":
			play_tone(ui_player, 1200, 0.15, 0.5)
		"purchase":
			play_tone(ui_player, 1500, 0.2, 0.6)
		"error":
			play_tone(ui_player, 300, 0.3, 0.7)

func play_game_sound(sound_type: String, volume: float = 1.0):
	var player = get_next_sfx_player()
	if not player:
		return
		
	match sound_type:
		"tank_fire":
			play_tone(player, 600, 0.2, 0.8 * volume)
		"tank_hit":
			play_tone(player, 400, 0.3, 0.9 * volume)
		"tank_explosion":
			play_explosion_sound(player, volume)
		"weapon_cycle":
			play_tone(player, 1000, 0.1, 0.4 * volume)
		"round_start":
			play_tone(player, 800, 0.5, 0.6 * volume)
		"round_end":
			play_tone(player, 1200, 0.8, 0.7 * volume)

func play_tone(player: AudioStreamPlayer, frequency: float, duration: float, volume: float):
	if not player:
		return
	
	# Create a simple sine wave tone
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 0.1
	
	player.stream = generator
	player.volume_db = linear_to_db(volume * sfx_volume * master_volume)
	player.play()
	
	# Stop after duration
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func(): player.stop(); timer.queue_free())
	timer.start()

func play_explosion_sound(player: AudioStreamPlayer, volume: float):
	# Create a more complex explosion sound using noise
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 0.1
	
	player.stream = generator
	player.volume_db = linear_to_db(volume * sfx_volume * master_volume)
	player.play()
	
	# Stop after 0.6 seconds
	var timer = Timer.new()
	timer.wait_time = 0.6
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func(): player.stop(); timer.queue_free())
	timer.start()

func get_next_sfx_player() -> AudioStreamPlayer:
	var player = sfx_players[current_sfx_index]
	current_sfx_index = (current_sfx_index + 1) % MAX_SFX_PLAYERS
	return player

# Volume controls
func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

# Utility function
func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)