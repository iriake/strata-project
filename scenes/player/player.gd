## Controla el comportamiento del jugador en el proyecto "Strata".
## Gestiona el movimiento 3D, la transición a una perspectiva 2D (mecánica Change)
## y la sincronización de animaciones del modelo visual.
class_name Player2
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
var _original_scales := {}

# Variables para restaurar profundidad en 3D
var _player_pos_before_2d := Vector3.ZERO
var _initial_platform: Node3D = null
var _offset_on_lock_axis := 0.0

# --- VARIABLES INTERNAS Y FÍSICA ---
## Dirección del último movimiento realizado, usada para mantener la orientación del modelo en reposo.
var _last_movement_direction := Vector3.BACK
## Valor de aceleración gravitatoria constante.
var _gravity := -30.0

# --- REFERENCIAS A NODOS (%) ---
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _camera_handler: Node = %CameraHandler

# Referencias a los visuales y colisiones
@onready var _skin_george: Node3D = $George
@onready var _skin_mini: Node3D = $MiniRobot
@onready var _col_george: CollisionShape3D = $CollisionGeorge
@onready var _col_mini: CollisionShape3D = $CollisionMini
@onready var _gpu_particles_3d: GPUParticles3D = $GPUParticles3D

# Variables de estado de transformación
var is_george_active := true
var _active_skin: Node3D # Puntero dinámico que usaremos en cosmetics

func _ready() -> void:
	_active_skin = _skin_george
	_skin_george.show()
	_col_george.set_deferred("disabled", false)
	
	_skin_mini.hide()
	_col_mini.set_deferred("disabled", true)

func _unhandled_input(event: InputEvent) -> void:
	# --- CAMBIO DE DIMENSIÓN ---
	if event.is_action_pressed("change_dimension"):
		toggle_change()
	
	# --- CAMBIO DE ROBOT ---
	if event.is_action_pressed("transform"):
		toggle_robot()

func _physics_process(delta: float) -> void:
	# 1. INPUT Y DIRECCIÓN
	var raw_input := Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var forward: Vector3
	var right: Vector3

	# Determinar ejes según la cámara (especial para TOP)
	if abs(_camera.global_transform.basis.z.y) > 0.9:
		var yaw := _camera_pivot.global_rotation.y
		forward = Vector3.FORWARD.rotated(Vector3.UP, yaw)
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

func toggle_robot() -> void:
	_gpu_particles_3d.restart()
	is_george_active = !is_george_active
	
	if is_george_active:
		_active_skin = _skin_george
		_skin_george.show()
		_skin_mini.hide()
		
		# Cambiamos colisiones de forma segura
		_col_george.set_deferred("disabled", false)
		_col_mini.set_deferred("disabled", true)
	else:
		_active_skin = _skin_mini
		_skin_george.hide()
		_skin_mini.show()
		
		_col_george.set_deferred("disabled", true)
		_col_mini.set_deferred("disabled", false)


## Cambia el estado del juego entre 3D y 2D, calculando los ejes de bloqueo según la cámara.
func toggle_change() -> void:
	is_2d_mode = !is_2d_mode

	if is_2d_mode:
		_enter_change_mode()
	else:
		_exit_change_mode()


func _enter_change_mode() -> void:
	var basis_z = _camera_pivot.global_basis.z

	# 1. Guardar posición absoluta y plataforma inicial antes del aplanamiento
	_player_pos_before_2d = global_position
	_initial_platform = _get_platform_underneath()

	# 2. Definir eje bloqueado y valor de bloqueo
	if abs(basis_z.y*2) > 0.9:
		_lock_axis = Vector3(0, 1, 0)
		_locked_position_value = -0.5
	elif abs(basis_z.z) > abs(basis_z.x):
		_lock_axis = Vector3(0, 0, 1)
		_locked_position_value = 0.0
	else:
		_lock_axis = Vector3(1, 0, 0)
		_locked_position_value = 0.0

	# 3. Calcular offset en el eje bloqueado
	if _initial_platform:
		if _lock_axis.x > 0:
			_offset_on_lock_axis = _player_pos_before_2d.x - _initial_platform.global_position.x
		elif _lock_axis.y > 0:
			_offset_on_lock_axis = _player_pos_before_2d.y - _initial_platform.global_position.y
		elif _lock_axis.z > 0:
			_offset_on_lock_axis = _player_pos_before_2d.z - _initial_platform.global_position.z
	else:
		if _lock_axis.x > 0:
			_offset_on_lock_axis = _player_pos_before_2d.x
		elif _lock_axis.y > 0:
			_offset_on_lock_axis = 0.0
		elif _lock_axis.z > 0:
			_offset_on_lock_axis = _player_pos_before_2d.z

	_move_mask = Vector3.ONE - _lock_axis

	# 4. Aplicar cambios a la posición del jugador
	if _lock_axis.x > 0:
		global_position.x = _locked_position_value
	elif _lock_axis.z > 0:
		global_position.z = _locked_position_value
	elif _lock_axis.y > 0:
		global_position.y = 0.0

	_project_world()
	_camera_pivot.force_2d_angle(true)
	
	# Delegado al controlador de cámara
	_camera_handler.set_camera_projection(true)


func _project_world() -> void:
	var objects = get_tree().get_nodes_in_group("change_geometry")
	_original_positions.clear()
	_original_scales.clear()

	for obj in objects:
		_original_positions[obj] = obj.global_position
		_original_scales[obj] = obj.scale
		
		var pos = obj.global_position
		var scl = obj.scale

		if _lock_axis.x > 0:
			pos.x = _locked_position_value
			scl.x = 1.0
		elif _lock_axis.z > 0:
			pos.z = _locked_position_value
			scl.z = 1.0
		elif _lock_axis.y > 0:
			pos.y = _locked_position_value
			scl.y = 1.0  # ← aplasta la escala Y para vista TOP

		obj.global_position = pos
		obj.scale = scl


func _restore_world() -> void:
	for obj in _original_positions:
		if is_instance_valid(obj):
			obj.global_position = _original_positions[obj]

	for obj in _original_scales:
		if is_instance_valid(obj):
			obj.scale = _original_scales[obj]

	_original_positions.clear()
	_original_scales.clear()


func _exit_change_mode() -> void:
	_restore_player_depth()

	_restore_world()

	_move_mask = Vector3.ONE

	_camera_pivot.force_2d_angle(false)
	
	# Delegado al controlador de cámara
	_camera_handler.set_camera_projection(false)


func _restore_player_depth() -> void:
	var current_platform = _get_platform_underneath()

	if current_platform:
		# ¿Tenemos guardada su posición original?
		if _original_positions.has(current_platform):
			var original_pos = _original_positions[current_platform]

			# Restauramos SOLO el eje aplastado
			if _lock_axis.x > 0:
				if _initial_platform == current_platform:
					global_position.x = _player_pos_before_2d.x
				else:
					var original_scale = _original_scales.get(current_platform, Vector3.ONE)
					var max_offset = max(0.0, original_scale.x / 2.0 - 0.2)
					var clamped_offset = clamp(_offset_on_lock_axis, -max_offset, max_offset)
					global_position.x = original_pos.x + clamped_offset

			elif _lock_axis.y > 0:
				var original_scale = _original_scales.get(current_platform, Vector3.ONE)
				global_position.y = original_pos.y + original_scale.y / 2.0

			elif _lock_axis.z > 0:
				if _initial_platform == current_platform:
					global_position.z = _player_pos_before_2d.z
				else:
					var original_scale = _original_scales.get(current_platform, Vector3.ONE)
					var max_offset = max(0.0, original_scale.z / 2.0 - 0.2)
					var clamped_offset = clamp(_offset_on_lock_axis, -max_offset, max_offset)
					global_position.z = original_pos.z + clamped_offset
		else:
			_restore_absolute_fallback()
	else:
		_restore_absolute_fallback()


func _restore_absolute_fallback() -> void:
	if _lock_axis.x > 0:
		global_position.x = _player_pos_before_2d.x
	elif _lock_axis.y > 0:
		global_position.y = _player_pos_before_2d.y
	elif _lock_axis.z > 0:
		global_position.z = _player_pos_before_2d.z


## Retorna el collider que está debajo del jugador mediante un raycast.
func _get_platform_underneath() -> Node3D:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1.0, 0),
		global_position + Vector3(0, -3.0, 0)
	)
	query.exclude = [get_rid()]
	var result = space.intersect_ray(query)
	if result:
		return result["collider"] as Node3D
	return null


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
		global_position.y = 0.0 # jugador siempre encima de los bloques aplanados


## Gestiona la rotación del modelo visual y dispara las animaciones correspondientes.
func _handle_cosmetics(move_direction: Vector3, delta: float, is_starting_jump: bool) -> void:
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		_skin_george.global_rotation.y = lerp_angle(_skin_george.rotation.y, target_angle, rotation_speed * delta)
		_skin_mini.global_rotation.y = lerp_angle(_skin_mini.rotation.y, target_angle, rotation_speed * delta)
	if is_starting_jump:
		_active_skin.jump()
	elif is_on_floor():
		var ground_speed := velocity.length()

		if ground_speed > 0.0: _active_skin.move()
		else: 
			if Input.is_action_pressed("emote"): _active_skin.dance()
			else:
				_active_skin.idle()
	else:
		_active_skin.fall()
