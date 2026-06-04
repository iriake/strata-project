## Nodo controlador del pivot de la cámara para el proyecto "Strata".
## Gestiona rotaciones incrementales, vistas fijas y ajustes de ángulo para el modo 2D.
class_name CameraPivot
extends Node3D

# --- CONFIGURACIÓN ---
## Tiempo que tarda la cámara en completar cualquier transición de ángulo.
@export var transition_time := 0.3

# --- VARIABLES DE ESTADO ---
## Almacena el destino acumulado de la rotación en el eje Y (giros laterales).
var _target_rotation_y := 0.0
## Almacena el destino del ángulo de inclinación en el eje X (vista arriba/abajo).
var _target_rotation_x := 0.0
## Referencia al Tween activo para permitir la interrupción y reinicio de animaciones.
var _current_tween: Tween

## Inicializa los valores de destino con la rotación actual del nodo al arrancar.
func _ready() -> void:
	_target_rotation_y = rotation.y
	_target_rotation_x = rotation.x
	
## Ejecuta una rotación lateral incremental de 90 grados.
## [param direction]: 1.0 para giro anti-horario, -1.0 para giro horario.
func side_rotation(direction: float):
	if _current_tween:
		_current_tween.kill()
	
	# Sumamos/restamos 90 grados (PI/2) al acumulador
	_target_rotation_y += (PI / 2.0) * direction
	
	_start_transition()
	
## Cambia la inclinación de la cámara a una posición predefinida (Top o Reset).
## [param view]: "top" para vista cenital, "reset" para la inclinación 3D estándar.
func set_fixed_view(view: String):
	if _current_tween:
		_current_tween.kill()
	
	match view:
		# Se resta 0.05 para dar una inclinación muy sutil en 3D cenital (cercana a 90°)
		"top": _target_rotation_x = (PI / 2.0) - 0.05
		# Inclinación default de 22.5 grados para profundidad 3D
		"reset": _target_rotation_x = PI / 8.0
	
	_start_transition()

## Ajusta el ángulo X para lograr una perspectiva de plataformas 2D pura.
## [param enabled]: Si es true, endereza la cámara a 0° (salvo en vista Top).
func force_2d_angle(enabled: bool):
	if _current_tween:
		_current_tween.kill()
	
	var is_top_view := false
	
	if enabled:
		# Si estamos en vista superior (desviación de hasta 0.11), forzamos a 90 grados exactos (PI / 2)
		if abs(_target_rotation_x - PI / 2.0) <= 0.11:
			_target_rotation_x = PI / 2.0
			is_top_view = true
		else:
			_target_rotation_x = 0.0
	else:
		# Al restaurar 3D:
		if abs(_target_rotation_x - PI / 2.0) < 0.01:
			# Volvemos a la inclinación 3D cenital con desviación de 0.05
			_target_rotation_x = (PI / 2.0) - 0.05
			is_top_view = true
		elif abs(_target_rotation_x) < 0.1:
			# Volvemos a la inclinación 3D estándar
			_target_rotation_x = PI / 8.0
	
	if is_top_view:
		# Transición súper rápida (0.08s) en vista cenital para suavizar el impacto sin revelar el deslizamiento
		_start_custom_transition(0.12)
	else:
		# Transición estándar suave (0.3s) para las demás vistas
		_start_transition()

## Helper para iniciar transiciones con duraciones personalizadas
func _start_custom_transition(duration: float):
	_current_tween = create_tween().set_parallel(true)
	_current_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_current_tween.tween_property(self, "rotation:y", _target_rotation_y, duration)
	_current_tween.tween_property(self, "rotation:x", _target_rotation_x, duration)

## Configura e inicia el sistema de interpolación (Tween) para mover la cámara.
## Utiliza una transición SINE_OUT para un movimiento fluido y responsivo.
func _start_transition():
	# set_parallel(true) permite que X e Y animen simultáneamente
	_current_tween = create_tween().set_parallel(true)
	_current_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Interpola las propiedades de rotación hacia los valores objetivo acumulados
	_current_tween.tween_property(self, "rotation:y", _target_rotation_y, transition_time)
	_current_tween.tween_property(self, "rotation:x", _target_rotation_x, transition_time)
