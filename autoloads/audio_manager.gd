extends Node

var music_player: AudioStreamPlayer

func _ready() -> void:
	# Asegurar que la música no se pause cuando el juego esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Intentar obtener el MusicPlayer si el autoload se cargó desde la escena .tscn
	if has_node("MusicPlayer"):
		music_player = $MusicPlayer as AudioStreamPlayer
		music_player.bus = "Music"
	else:
		# Si se cargó directamente como script .gd, creamos el MusicPlayer dinámicamente
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		music_player.bus = "Music"
		add_child(music_player)
	
	play_music()

func play_music() -> void:
	if music_player:
		if not music_player.stream:
			var stream = load("res://assets/audio/Exploding Sun.mp3")
			if stream:
				music_player.stream = stream
			else:
				printerr("[AudioManager] ERROR: No se pudo cargar res://assets/audio/Exploding Sun.mp3")
				return
		
		# Solo reproducir si no está sonando ya
		if not music_player.playing:
			music_player.play()
			print("[AudioManager] Reproduciendo música de fondo: ", music_player.stream.resource_path)

func play_sfx(sfx: AudioStream, volume_db: float = 0.0) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = sfx
	player.bus = "SFX"
	player.volume_db = volume_db
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()
