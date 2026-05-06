extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer


func _ready() -> void:
	play_music()

func play_music() -> void:
	music_player.play()

func play_sfx(sfx: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = sfx
	player.bus = "SFX"
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()
