extends Control

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var vbox_container: VBoxContainer = $ScrollContainer/VBoxContainer

@export var velocidad_scroll: float = 45.0 # Velocidad en píxeles por segundo
var scroll_actual: float = 0.0

func _ready() -> void:
	# Forzamos a que empiece abajo del todo
	scroll_container.scroll_vertical = 0
	scroll_actual = 0.0

func _process(delta: float) -> void:
	# Movimiento suave flotante e independiente de los FPS
	scroll_actual += velocidad_scroll * delta
	scroll_container.scroll_vertical = int(scroll_actual)
	
	# Detectar el final del scroll para reiniciarlo en bucle
	var barra_v = scroll_container.get_v_scroll_bar()
	var limite_maximo = barra_v.max_value - barra_v.page
	
	if scroll_actual >= limite_maximo:
		scroll_actual = 0.0 # Reinicia la cascada automáticamente

func _input(event: InputEvent) -> void:
	# Detecta si el jugador presiona Escape para volver al menú anterior
	if event.is_action_pressed("menu") or (event is InputEventKey and event.keycode == KEY_ESCAPE):
		get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
