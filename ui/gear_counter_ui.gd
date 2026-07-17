extends CanvasLayer

@onready var label: Label = $MarginContainer/HBoxContainer/Label
@onready var gear_logo: Area3D = $MarginContainer/HBoxContainer/SubViewportContainer/SubViewport/Collectible_Gear

@export var rotation_speed: float = 3.0

func _process(delta: float) -> void:
	if is_instance_valid(gear_logo):
		gear_logo.rotate_y(rotation_speed * delta)

# Función para actualizar el texto en pantalla (ej: "03/10")
func actualizar_conteo(actuales: int, totales: int) -> void:
	# String.format_values o format para forzar los dos dígitos estilo retro ("03")
	var actuales_str = str(actuales).pad_zeros(2)
	var totales_str = str(totales).pad_zeros(2)
	label.text = actuales_str + " / " + totales_str
