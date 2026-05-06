# player_movement.gd
# Constantes y lógica de movimiento separadas del player principal.
# Player.gd llama a las funciones de este script si se decide modularizar.
# Por ahora actúa como referencia de valores y helpers.

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const ACCELERATION: float = 10.0
const GRAVITY_MULTIPLIER: float = 1.0


static func get_input_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_front", "move_back")


static func get_world_direction(basis: Basis, input_dir: Vector2) -> Vector3:
	return (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


static func apply_horizontal_movement(
	velocity: Vector3,
	direction: Vector3,
	speed: float,
	acceleration: float,
	delta: float
) -> Vector3:
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)
	return velocity
