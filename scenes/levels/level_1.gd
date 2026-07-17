extends Node3D

@onready var gear_counter_ui = $GearCounterUI

var total_gears: int = 0
var gears_recolectados: int = 0

func _ready() -> void:
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
