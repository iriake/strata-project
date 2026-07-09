extends CanvasLayer

@onready var texto_mensaje: RichTextLabel = $MarginContainer/ColorRect/RichTextLabel

func _ready() -> void:
	# El sistema empieza totalmente oculto
	hide()

# Función universal para mostrar cualquier mensaje por X segundos
func mostrar_mensaje(texto_bbcode: String, duracion: float) -> void:
	texto_mensaje.text = texto_bbcode
	show()
	
	# Creamos un temporizador rápido por código
	await get_tree().create_timer(duracion, false).timeout
	
	# Al terminar el tiempo, lo ocultamos
	hide()
