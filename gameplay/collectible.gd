extends Area3D

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
	var player = body as Player2
	if player:
		monitoring = false
		get_tree().reload_current_scene()
		
func _physics_process(delta: float) -> void:
	target_angle += 3 * delta
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
	
	angle += float_speed * delta
	global_position.y = start_y + (sin(angle) * float_amplitude)	
	
