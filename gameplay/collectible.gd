extends Area3D

# Señal para avisarle al nivel que este engranaje específico fue recolectado
signal recolectado(engranaje)

@export var rotation_speed := 12.0
@export var float_speed := 3.0
@export var float_amplitude: float = 0.3

var target_angle := 0.0
var angle: float = 0.0
var start_y: float

func _ready() -> void:
	start_y = global_position.y
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Asumiendo que tu script de jugador se llama Player2
	if body is Player2:
		# Desactivamos colisiones inmediatamente para evitar doble recolección
		monitoring = false
		# Emitimos la señal avisando al nivel
		recolectado.emit(self)
		# Nos destruimos
		queue_free()
		
func _physics_process(delta: float) -> void:
	target_angle += 3 * delta
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
	
	angle += float_speed * delta
	global_position.y = start_y + (sin(angle) * float_amplitude)
