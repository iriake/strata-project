extends Control

@onready var resume: Button = %Resume
@onready var retry: Button = %Retry
@onready var settings: Button = %Settings
@onready var main_menu: Button = %MainMenu
@onready var save_game: Button = %SaveGame
@onready var load_game: Button = %LoadGame


func  _ready() -> void:
	hide()
	resume.pressed.connect(_on_resume_pressed)
	retry.pressed.connect(_on_retry_pressed)
	settings.pressed.connect(_on_settings_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)
	save_game.pressed.connect(_on_save_game_pressed)
	load_game.pressed.connect(_on_load_game_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused


func _on_resume_pressed() -> void:
	get_tree().paused =  false
	hide()


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_settings_pressed() -> void:
	Debug.log("TODO")


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	LevelManager.main_menu()


func _on_save_game_pressed() -> void:
	var dict: Dictionary = {
		"name": "Pepito",
		"attack": 10.2,
		"coins": Game.coins
	}
	var dict_string = JSON.stringify(dict)
	
	var file = FileAccess.open_encrypted_with_pass("user://save.data", FileAccess.WRITE, "1234")
	file.store_string(dict_string)
	
	var config = ConfigFile.new()

	# Store some values.
	config.set_value("Video", "fullscreen", false)
	config.set_value("Video", "V-Sync", true)
	config.set_value("Audio", "music_volume", 0.7)
	config.set_value("Audio", "sfx_volume", 0.9)

	config.save("user://settings.cfg")


func _on_load_game_pressed() -> void:
	var file = FileAccess.open_encrypted_with_pass("user://save.data", FileAccess.READ, "1234")
	var dict: Dictionary = JSON.parse_string(file.get_as_text())
	Debug.log(dict.name)
	Debug.log(dict.attack)
	Game.coins = dict.coins
	
	var config = ConfigFile.new()
	
	config.load("user://settings.cfg")

	for section in config.get_sections():
		for key in config.get_section_keys(section):
			Debug.log("[%s] %s: %s" %  [section, key, config.get_value(section, str(key))])
			var string: String = "hola: %s , %d -- %.2f" % ["pepito", 123, 3.0/7.0]
			Debug.log(string)
