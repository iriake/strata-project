extends Node

@export var main_menu_scene: PackedScene
@export var credits_scene: PackedScene
@export var levels: Array[PackedScene]

var current_level = 0

@onready var _pause_menu = $PauseMenu

func start() -> void:
	current_level = 0
	if not levels.is_empty():
		get_tree().change_scene_to_packed(levels[0])

func next_level() -> void:
	current_level += 1
	if current_level < levels.size():
		get_tree().change_scene_to_packed(levels[current_level])
	else:
		credits()


func main_menu() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func credits() -> void:
	get_tree().change_scene_to_packed(credits_scene)

func _input(event: InputEvent) -> void:
	# si se presiona menu
	if event.is_action_pressed("menu"):
		# variable para la ruta de la escena actual
		var current = get_tree().current_scene.scene_file_path
		var is_in_level = current != main_menu_scene.resource_path and current != credits_scene.resource_path
		# si no estamos ni en menu ni en creditos
		if is_in_level:
			# pausamos o reanudamos
			get_tree().paused = not get_tree().paused
			_pause_menu.visible = get_tree().paused
