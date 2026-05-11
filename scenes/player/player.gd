## Controla el comportamiento del jugador en el proyecto "Strata".
## Gestiona el movimiento 3D, la transición a una perspectiva 2D (mecánica Change)
## y la sincronización de animaciones del modelo visual.
class_name Player
extends CharacterBody3D

# --- CONFIGURACIÓN DE MOVIMIENTO ---
@export_group("Movement")
## Velocidad máxima alcanzable al caminar.
@export var move_speed := 8.0
## Factor de aceleración y frenado (fricción).
@export var acceleration := 20.0
## Rapidez con la que el modelo visual se orienta hacia la dirección de marcha.
@export var rotation_speed := 12.0
## Fuerza aplicada instantáneamente hacia arriba al saltar.
@export var jump_impulse := 12.0

# --- ESTADO DE LA MECÁNICA CHANGE (2D) ---
## Indica si el jugador se encuentra actualmente en el modo de perspectiva aplastada.
var is_2d_mode := false
## Vector que define qué eje espacial está bloqueado (ej: Vector3(0,0,1) bloquea la profundidad en Z).
var _lock_axis := Vector3.ZERO
## Almacena la coordenada exacta en el eje bloqueado al activar el Crush para evitar desviaciones.
var _locked_position_value := 0.0
## Multiplicador que anula la velocidad en el eje bloqueado (ej: Vector3(1,1,0) permite mover en X e Y pero no en Z).
var _move_mask := Vector3.ONE
# Posiciones originales de los objetos
var _original_positions := {}

# --- VARIABLES INTERNAS Y FÍSICA ---
## Dirección del último movimiento realizado, usada para mantener la orientación del modelo en reposo.
var _last_movement_direction := Vector3.BACK
## Valor de aceleración gravitatoria constante.
var _gravity := -30.0

# --- REFERENCIAS A NODOS (%) ---
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %UAL1_Standard


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

	# --- CAMBIO DE DIMENSIÓN ---
	if event.is_action_pressed("change_dimension"):
		toggle_change()


func _physics_process(delta: float) -> void:
	# 1. INPUT Y DIRECCIÓN
	var raw_input := Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var forward: Vector3
	var right: Vector3

	# Determinar ejes según la cámara (especial para TOP)
	if abs(_camera.global_transform.basis.z.y) > 0.9:
		forward = -_camera_pivot.global_basis.z
		right = -_camera_pivot.global_basis.x
	else:
		forward = _camera.global_basis.z
		right = _camera.global_basis.x

	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	# 2. VELOCIDAD HORIZONTAL
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)

	# 3. FÍSICA SEGÚN MODO
	if is_2d_mode:
		velocity *= _move_mask
		velocity.y = y_velocity + _gravity * delta
		_snap_to_lock_axis()
	else:
		velocity.y = y_velocity + _gravity * delta

	# 4. SALTO Y MOVIMIENTO
	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y = jump_impulse

	move_and_slide()

	# 5. ANIMACIONES
	_handle_cosmetics(move_direction, delta, is_starting_jump)

## Cambia el estado del juego entre 3D y 2D, calculando los ejes de bloqueo según la cámara.
func toggle_change() -> void:
	is_2d_mode = !is_2d_mode

	if is_2d_mode:
		_enter_change_mode()
	else:
		_exit_change_mode()

func _enter_change_mode() -> void:
	var basis_z = _camera_pivot.global_basis.z

	if abs(basis_z.y) > 0.9:
		_lock_axis = Vector3(0, 1, 0)
		_locked_position_value = -0.5   # bloques se aplanan aquí
		global_position.y = 0.5         # jugador queda encima de los bloques
	elif abs(basis_z.z) > abs(basis_z.x):
		_lock_axis = Vector3(0, 0, 1)
		_locked_position_value = 0.0
	else:
		_lock_axis = Vector3(1, 0, 0)
		_locked_position_value = 0.0

	_move_mask = Vector3.ONE - _lock_axis

	if _lock_axis.x > 0: global_position.x = _locked_position_value
	elif _lock_axis.z > 0: global_position.z = _locked_position_value
	# No tocamos Y aquí para TOP porque ya lo seteamos arriba

	_project_world()
	_camera_pivot.force_2d_angle(true)
	_set_camera_projection(true)

func _project_world() -> void:
	var objects = get_tree().get_nodes_in_group("change_geometry")
	_original_positions.clear()

	for obj in objects:
		_original_positions[obj] = obj.global_position
		var pos = obj.global_position

		if _lock_axis.x > 0:
			pos.x = _locked_position_value
		elif _lock_axis.z > 0:
			pos.z = _locked_position_value
		elif _lock_axis.y > 0:
			pos.y = _locked_position_value  # ← aplasta en Y para vista TOP

		obj.global_position = pos

func _restore_world() -> void:
	for obj in _original_positions:
		if is_instance_valid(obj):
			obj.global_position = _original_positions[obj]

	_original_positions.clear()

func _exit_change_mode() -> void:
	_restore_player_depth()

	_restore_world()

	_move_mask = Vector3.ONE

	_camera_pivot.force_2d_angle(false)
	_set_camera_projection(false)

func _restore_player_depth() -> void:
	var space = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1, 0),
		global_position + Vector3(0, -3, 0)
	)

	query.exclude = [get_rid()]

	var result = space.intersect_ray(query)

	if result:
		var collider = result["collider"]

		# ¿Tenemos guardada su posición original?
		if _original_positions.has(collider):

			var original_pos = _original_positions[collider]

			# Restauramos SOLO el eje aplastado
			if _lock_axis.x > 0:
				global_position.x = original_pos.x

			elif _lock_axis.y > 0:
				global_position.y = original_pos.y + 1.0

			elif _lock_axis.z > 0:
				global_position.z = original_pos.z

## Al volver al modo 3D, hace un raycast hacia abajo para encontrar la plataforma
## y corrige la posición en el eje bloqueado usando la posición real de esa plataforma.
func _restore_3d_position() -> void:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1, 0),
		global_position + Vector3(0, -3, 0)
	)
	query.exclude = [get_rid()]
	var result = space.intersect_ray(query)

	if result:
		var platform_pos = result["collider"].global_position
		# Corregimos solo el eje bloqueado usando la posición real de la plataforma
		if _lock_axis.z > 0:
			global_position.z = platform_pos.z
		elif _lock_axis.x > 0:
			global_position.x = platform_pos.x
		elif _lock_axis.y > 0:
			global_position.y = platform_pos.y + 5.0


## Asegura que el personaje no se desplace fuera del eje bloqueado durante el modo 2D.
func _snap_to_lock_axis() -> void:
	if _lock_axis.x > 0:
		global_position.x = _locked_position_value
	elif _lock_axis.z > 0:
		global_position.z = _locked_position_value
	elif _lock_axis.y > 0:
		global_position.y = 2 # jugador siempre encima de los bloques aplanados


## Cambia el modo de proyección de la cámara (Perspectiva ↔ Ortográfica).
func _set_camera_projection(is_ortho: bool) -> void:
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL if is_ortho else Camera3D.PROJECTION_PERSPECTIVE
	_camera.size = 12.0


## Gestiona la rotación del modelo visual y dispara las animaciones correspondientes.
func _handle_cosmetics(move_direction: Vector3, delta: float, is_starting_jump: bool) -> void:
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	if is_starting_jump:
		_skin.jump()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		var is_crouch := Input.is_action_pressed("crouch")
		var ground_speed := velocity.length()

		if is_crouch:
			if ground_speed > 0.0: _skin.crouch_move()
			else: _skin.crouch_idle()
		else:
			if ground_speed > 0.0: _skin.move()
			else: _skin.idle()
