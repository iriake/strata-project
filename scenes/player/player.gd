class_name Player
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 10.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Movimiento
	var input_dir := Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)

	move_and_slide()
