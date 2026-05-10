## Controla el comportamiento del jugador, incluyendo movimiento 3D, cámara y animaciones.
class_name Player
extends CharacterBody3D

@export_group("Camera")
## Sensibilidad del ratón para el movimiento de la cámara.
@export_range(0.0, 1.0) var mouse_sensitivility := 0.25

@export_group("Movement")
## Velocidad máxima al caminar.
@export var move_speed := 8.0
## Fuerza con la que el personaje acelera y frena.
@export var acceleration := 20.0
## Velocidad de giro del modelo visual hacia la dirección del movimiento.
@export var rotation_speed := 12.0
## Fuerza del impulso ascendente al saltar.
@export var jump_impulse := 12.0

# Variables para el manejo de la cámara y física interna
var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var _gravity := -30.0
var _is_2d_mode := false
var _active_perspective = null
var _locked_depth: float = 0.0

# Referencias a nodos mediante nombres únicos de escena (%)
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %UAL1_Standard
@export var depth_snap_radius: float = 5.0

func _input(event: InputEvent) -> void:
	# Captura el cursor al hacer click para poder mover la cámara
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Libera el cursor si se presiona la tecla de cancelar (Ctrl)
	if event.is_action_pressed("iu_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	# Detecta el movimiento del ratón solo si está capturado por el juego
	var is_camera_motion := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion and not _is_2d_mode:
		_camera_input_direction = event.screen_relative * mouse_sensitivility
		
func _physics_process(delta: float) -> void:
	# --- Rotación de Cámara ---
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	# Limita la rotación vertical para evitar que la cámara de la vuelta completa
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)		
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	# Limpia el input del ratón para que no se siga moviendo solo
	_camera_input_direction = Vector2.ZERO
	
	# --- Cálculo de Dirección de Movimiento ---
	var raw_input := Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var foward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	# Calcula la dirección relativa a la cámara pero ignorando el eje Y
	var move_direction := foward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0

	if _is_2d_mode:
		move_direction = _get_2d_move_direction(raw_input)
	else:
		var forward := _camera.global_basis.z
		move_direction = forward * raw_input.y + right * raw_input.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized()

	move_direction = move_direction.normalized()
	
	# --- Gestión de Velocidad y Gravedad ---
	var y_velocity := velocity.y
	velocity.y = 0.0 # Separa la velocidad horizontal de la vertical para el cálculo
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity + _gravity * delta
	
	# Detecta si se inicia un salto estando en el suelo
	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_impulse
	
	# Ejecuta el movimiento y gestiona colisiones
	move_and_slide()
	
	if _is_2d_mode:
		_lock_depth_axis()
	
	# --- Rotación del Modelo Visual ---
	# Gira el modelo hacia la dirección de movimiento si esta es significativa
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
		
	
	# --- Lógica de Animaciones (Skin) ---
	if is_starting_jump:
		_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		var is_crouch := Input.is_action_pressed("crouch")
		var ground_speed := velocity.length()
		if is_crouch:
			if ground_speed > 0.0:
				_skin.crouch_move()
			else:
				_skin.crouch_idle()
		else:
			if ground_speed > 0.0:
				_skin.move()
			else:
				_skin.idle()

func set_dimension_mode(mode, perspective, locked_depth: float = 0.0) -> void:
	if mode == DimensionSystem.DimensionMode.MODE_2D:
		_is_2d_mode = true
		_active_perspective = perspective
		_locked_depth = locked_depth
	else:
		_is_2d_mode = false

# movimiento permitido al cambiar en 2D
func _get_2d_move_direction(raw_input: Vector2) -> Vector3:
	# En 2D, el input.x siempre es izquierda/derecha en pantalla
	# El input.y es arriba/abajo (no se usa, el salto lo maneja jump)
	match _active_perspective:
		DimensionSystem.Perspective.FRONT:
			# Cámara mira desde +Z hacia -Z: moverse en X
			return Vector3(raw_input.x, 0, 0).normalized()
		DimensionSystem.Perspective.BACK:
			# Cámara mira desde -Z: X invertido
			return Vector3(-raw_input.x, 0, 0).normalized()
		DimensionSystem.Perspective.LEFT:
			# Cámara mira desde -X: moverse en Z
			return Vector3(0, 0, raw_input.x).normalized()
		DimensionSystem.Perspective.RIGHT:
			# Cámara mira desde +X: Z invertido
			return Vector3(0, 0, -raw_input.x).normalized()
		DimensionSystem.Perspective.TOP:
			# Si W te mandaba hacia abajo, invertimos raw_input.y
			# Si D te mandaba hacia la izquierda, invertimos raw_input.x
			return Vector3(-raw_input.x, 0, -raw_input.y).normalized()
	return Vector3.ZERO


func _lock_depth_axis() -> void:
	var space = get_world_3d().direct_space_state
	
	match _active_perspective:
		DimensionSystem.Perspective.FRONT, DimensionSystem.Perspective.BACK:
			var best_z = _locked_depth
			var best_score = INF
			
			for z_offset in [-8.0, -6.0, -4.0, -2.0, 0.0, 2.0, 4.0, 6.0, 8.0]:
				var probe = global_position
				probe.z = _locked_depth + z_offset
				var q = PhysicsRayQueryParameters3D.create(
					probe + Vector3(0, 0.5, 0),
					probe + Vector3(0, -3.0, 0)
				)
				q.exclude = [get_rid()]
				var r = space.intersect_ray(q)
				if r:
					var height_diff = global_position.y - r["position"].y
					if height_diff >= 0.0 and height_diff < best_score:
						best_score = height_diff
						best_z = r["position"].z
			
			_locked_depth = best_z
			
			if is_on_floor():
				velocity.z = 0.0
				global_position.z = _locked_depth
			else:
				global_position.z = lerp(global_position.z, _locked_depth, 0.15)

		DimensionSystem.Perspective.LEFT, DimensionSystem.Perspective.RIGHT:
			var best_x = _locked_depth
			var best_score = INF
			
			for x_offset in [-8.0, -6.0, -4.0, -2.0, 0.0, 2.0, 4.0, 6.0, 8.0]:
				var probe = global_position
				probe.x = _locked_depth + x_offset
				var q = PhysicsRayQueryParameters3D.create(
					probe + Vector3(0, 0.5, 0),
					probe + Vector3(0, -3.0, 0)
				)
				q.exclude = [get_rid()]
				var r = space.intersect_ray(q)
				if r:
					var height_diff = global_position.y - r["position"].y
					if height_diff >= 0.0 and height_diff < best_score:
						best_score = height_diff
						best_x = r["position"].x
			
			_locked_depth = best_x
			
			if is_on_floor():
				velocity.x = 0.0
				global_position.x = _locked_depth
			else:
				global_position.x = lerp(global_position.x, _locked_depth, 0.15)

		DimensionSystem.Perspective.TOP:
			velocity.y = 0.0
