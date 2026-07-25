extends Node3D # O Node3D, dependiendo de tu escena de nivel

@onready var tutorial_ui: CanvasLayer = $TutorialUI


@onready var gear_counter_ui = $GearCounterUI

var total_gears: int = 0
var gears_recolectados: int = 0


func _ready() -> void:
	# Esperamos un segundo para que el jugador se ubique en la pantalla
	await get_tree().create_timer(1.0, false).timeout
	
	# Mostramos el primer mensaje durante 5 segundos
	var msg1 = "[center]Usa [color=#00f3ff]WASD[/color] para moverte, ⬅️➡️⬆️⬇️ para cambiar la camara y [color=#ff0055]ESC[/color] para pausar[/center]"
	tutorial_ui.mostrar_mensaje(msg1, 5.0)
	
	# Esperamos a que termine (5s) + un pequeño respiro (1.5s)
	await get_tree().create_timer(6.5, false).timeout
	
	# Mostramos el segundo mensaje por otros 5 segundos
	var msg2 = "[center]Oprime [color=#00f3ff]Q[/color] para cambiar de dimensión, [color=#00f3ff]C[/color] para cambiar de personaje y [color=#00f3ff]E[/color] para hacer un emote[/center]"
	tutorial_ui.mostrar_mensaje(msg2, 5.0)

	# 1. Buscar todos los engranajes que pusiste físicamente en el mapa
	var engranajes = get_tree().get_nodes_in_group("engranajes")
	
	total_gears = engranajes.size()
	gears_recolectados = 0
	
	# 2. Conectar la señal de cada engranaje al script del nivel
	for gear in engranajes:
		if gear.has_signal("recolectado"):
			gear.recolectado.connect(_on_gear_recolectado)
			
	# 3. Inicializar la interfaz con el conteo inicial (ej: "00/05")
	gear_counter_ui.actualizar_conteo(gears_recolectados, total_gears)

# Se ejecuta automáticamente cada vez que recogemos un engranaje
func _on_gear_recolectado(gear_nodo: Node3D) -> void:
	gears_recolectados += 1
	
	# Actualizamos la UI en tiempo real
	gear_counter_ui.actualizar_conteo(gears_recolectados, total_gears)

	
	# Comprobar si ya los tenemos todos para avanzar
	if gears_recolectados >= total_gears:
		completar_nivel()

func completar_nivel() -> void:
	LevelManager.next_level()
	#get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")
