extends Control

signal back_pressed

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var back_button: Button = %BackButton

var _music_bus_idx: int
var _sfx_bus_idx: int

func _ready() -> void:
	_music_bus_idx = AudioServer.get_bus_index("Music")
	_sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	# Cargar los valores iniciales
	if _music_bus_idx != -1:
		var is_mute = AudioServer.is_bus_mute(_music_bus_idx)
		music_slider.value = 0.0 if is_mute else db_to_linear(AudioServer.get_bus_volume_db(_music_bus_idx))
		music_slider.value_changed.connect(_on_music_value_changed)
		
	if _sfx_bus_idx != -1:
		var is_mute = AudioServer.is_bus_mute(_sfx_bus_idx)
		sfx_slider.value = 0.0 if is_mute else db_to_linear(AudioServer.get_bus_volume_db(_sfx_bus_idx))
		sfx_slider.value_changed.connect(_on_sfx_value_changed)
		
	back_button.pressed.connect(_on_back_pressed)

func _on_music_value_changed(value: float) -> void:
	if _music_bus_idx != -1:
		if value <= 0.01:
			AudioServer.set_bus_mute(_music_bus_idx, true)
		else:
			AudioServer.set_bus_mute(_music_bus_idx, false)
			AudioServer.set_bus_volume_db(_music_bus_idx, linear_to_db(value))

func _on_sfx_value_changed(value: float) -> void:
	if _sfx_bus_idx != -1:
		if value <= 0.01:
			AudioServer.set_bus_mute(_sfx_bus_idx, true)
		else:
			AudioServer.set_bus_mute(_sfx_bus_idx, false)
			AudioServer.set_bus_volume_db(_sfx_bus_idx, linear_to_db(value))

func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()
