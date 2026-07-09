extends Node3D # O Node3D, dependiendo de tu escena de nivel

@onready var tutorial_ui: CanvasLayer = $TutorialUI


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
