extends Node

## Manipulador de cámara para el jugador.
## Gestiona las entradas de rotación de la cámara y cambios de proyección (Perspectiva ↔ Ortográfica).

@onready var _camera_pivot: CameraPivot = %CameraPivot
@onready var _camera: Camera3D = %Camera3D

## Tamaño de la proyección ortográfica (zoom de la cámara en modo 2D).
@export var ortho_size := 12.0

## Guarda la posición local que tenía la cámara en 3D justo antes de cambiar a 2D.
var _camera_local_position_before_2d := Vector3.ZERO

func _ready() -> void:
	_camera_local_position_before_2d = _camera.position

## Vinculación al estado 2D del jugador.
var is_2d_mode: bool:
	get:
		if get_parent() and "is_2d_mode" in get_parent():
			return get_parent().is_2d_mode
		return false


func _unhandled_input(event: InputEvent) -> void:
	# --- CONTROL DE CÁMARA (Bloqueado en modo 2D) ---
	if not is_2d_mode:
		if event.is_action_pressed("move_camera_right"):
			_camera_pivot.side_rotation(-1.0)
		elif event.is_action_pressed("move_camera_left"):
			_camera_pivot.side_rotation(1.0)
		elif event.is_action_pressed("move_camera_up"):
			_camera_pivot.set_fixed_view("top")
		elif event.is_action_pressed("move_camera_down"):
			_camera_pivot.set_fixed_view("reset")


## Cambia el modo de proyección de la cámara (Perspectiva ↔ Ortográfica).
## Resuelve el drift restaurando la posición local 3D original al salir.
func set_camera_projection(is_ortho: bool) -> void:
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL if is_ortho else Camera3D.PROJECTION_PERSPECTIVE
	_camera.size = ortho_size
	
	if is_ortho:
		# 1. Guardamos la posición local 3D actual calculada por el SpringArm
		_camera_local_position_before_2d = _camera.position
		# 2. Desplazamos globalmente hacia atrás para que no quede dentro del objeto
		_camera.global_position = _camera.global_position + _camera.global_basis.z * 10
	else: 
		# 3. Restauramos la posición local exacta de 3D, eliminando cualquier deriva por rotación
		_camera.position = _camera_local_position_before_2d
