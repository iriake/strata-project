## Controla el comportamiento del jugador, incluyendo movimiento 3D, cámara y animaciones.
class_name Player
extends CharacterBody3D

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

# Referencias a nodos mediante nombres únicos de escena (%)
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %UAL1_Standard

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_camera_right"):
		_camera_pivot.side_rotation(-1.0) # Gira 90° derecha
	elif event.is_action_pressed("move_camera_left"):
		_camera_pivot.side_rotation(1.0)  # Gira 90° izquierda
	elif event.is_action_pressed("move_camera_up"):
		_camera_pivot.set_fixed_view("top")
	elif event.is_action_pressed("move_camera_down"):
		_camera_pivot.set_fixed_view("reset")
	
func _physics_process(delta: float) -> void:
	# --- Cálculo de Dirección de Movimiento ---
	var raw_input := Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var foward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	# Calcula la dirección relativa a la cámara pero ignorando el eje Y
	var move_direction := foward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
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
