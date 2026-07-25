extends Control

@onready var advertencia: ConfirmationDialog = $Advertencia

# Usamos un enum para rastrear qué botón abrió el cuadro de confirmación
enum AccionConfirmar { NINGUNA, CARGAR, MENU_PRINCIPAL }
var accion_pendiente = AccionConfirmar.NINGUNA

func _ready() -> void:
	hide()
	# Aseguramos que los textos del diálogo nativo sean correctos
	advertencia.get_ok_button().text = "Sí, continuar"
	advertencia.get_cancel_button().text = "Cancelar"

# --- BOTÓN: RESUME ---
func _on_resume_pressed() -> void:
	# Despausamos simulando la misma lógica del LevelManager
	get_tree().paused = false
	visible = false

# --- BOTÓN: SAVE ---
func _on_save_pressed() -> void:
	# Aquí irá tu lógica de guardado futuro (ej: Guardado.save_game())
	pass

# --- BOTÓN: LOAD ---
func _on_load_pressed() -> void:
	accion_pendiente = AccionConfirmar.CARGAR
	advertencia.popup_centered()

# --- BOTÓN: RESTART ---
func _on_restart_pressed() -> void:
	visible = false
	# Es vital despausar antes de recargar la escena actual
	get_tree().paused = false
	get_tree().reload_current_scene()

# --- BOTÓN: OPTIONS ---
func _on_options_pressed() -> void:
	var settings = load("res://ui/settings_menu.tscn").instantiate()
	add_child(settings)

# --- BOTÓN: QUIT (Menú Principal) ---
func _on_quit_pressed() -> void:
	accion_pendiente = AccionConfirmar.MENU_PRINCIPAL
	advertencia.popup_centered()

# --- SEÑAL: "confirmed" de Advertencia ---
func _on_advertencia_confirmed() -> void:
	match accion_pendiente:
		AccionConfirmar.CARGAR:
			print("Cargando partida...")
			get_tree().paused = false
			visible = false
			
		AccionConfirmar.MENU_PRINCIPAL:
			visible = false
			get_tree().paused = false
			get_tree().change_scene_to_file("res://ui/MainMenu.tscn")

	accion_pendiente = AccionConfirmar.NINGUNA

# --- SEÑAL: "canceled" de Advertencia ---
func _on_advertencia_canceled() -> void:
	accion_pendiente = AccionConfirmar.NINGUNA
