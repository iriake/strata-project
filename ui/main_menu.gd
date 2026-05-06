extends Control

@onready var start: Button = %Start
@onready var quit: Button = %Quit
@onready var credits: Button = %Credits

func _ready() -> void:
	start.pressed.connect(_on_start_pressed)
	quit.pressed.connect(_on_quit_pressed)
	credits.pressed.connect(_on_credits_pressed)


func _on_start_pressed() -> void:
	LevelManager.start()
	
	
func _on_quit_pressed() -> void:
	get_tree().quit()
	
	
func _on_credits_pressed() -> void:
	LevelManager.credits()
