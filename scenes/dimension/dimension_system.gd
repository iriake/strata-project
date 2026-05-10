class_name DimensionSystem
extends Node3D

enum Perspective { FRONT, BACK, LEFT, RIGHT, TOP }
enum DimensionMode { MODE_3D, MODE_2D }

var current_mode: DimensionMode = DimensionMode.MODE_3D
var current_perspective: Perspective = Perspective.FRONT
var _saved_depth: float = 0.0

@export var player: Player
var camera_3d: Camera3D
var _camera_original_position: Vector3
var _camera_original_rotation: Vector3

func _ready() -> void:
	if player:
		camera_3d = player._camera
		_camera_original_position = camera_3d.position
		_camera_original_rotation = camera_3d.rotation_degrees

# ejes aplastados por perspectiva
const PERSPECTIVE_DATA = {
	Perspective.FRONT:  { "axis": "z", "dir": Vector3(0, 0,  1) },
	Perspective.BACK:   { "axis": "z", "dir": Vector3(0, 0, -1) },
	Perspective.LEFT:   { "axis": "x", "dir": Vector3( 1, 0, 0) },
	Perspective.RIGHT:  { "axis": "x", "dir": Vector3(-1, 0, 0) },
	Perspective.TOP:    { "axis": "y", "dir": Vector3(0,  1, 0) },
}

# entrar y salir de las dimensiones
func toggle_dimension() -> void:
	if current_mode == DimensionMode.MODE_3D:
		_choose_smart_perspective()
		_enter_2d()
	else:
		_exit_2d()
		
		
# input del cambio TAB
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("change_dimension"):
		toggle_dimension()


func _enter_2d() -> void:
	var data = PERSPECTIVE_DATA[current_perspective]
	
	# obtenemos la posición del bloque bajo los pies
	var entry_pos = _find_entry_plane(data)
	player.global_position = entry_pos
	
	# guardamos la profundidad del bloque, no la original
	_saved_depth = entry_pos[data["axis"]]
	
	current_mode = DimensionMode.MODE_2D
	
	# configuración de cámara para las distintas perspectivas
	var player_pos := player.global_position
	match current_perspective:
		Perspective.FRONT:
			camera_3d.global_position = player_pos + Vector3(0, 2, 15)
			camera_3d.look_at(player_pos + Vector3(0, 1, 0), Vector3.UP)
		Perspective.BACK:
			camera_3d.global_position = player_pos + Vector3(0, 2, -15)
			camera_3d.look_at(player_pos + Vector3(0, 1, 0), Vector3.UP)
		Perspective.LEFT:
			camera_3d.global_position = player_pos + Vector3(-15, 2, 0)
			camera_3d.look_at(player_pos + Vector3(0, 1, 0), Vector3.UP)
		Perspective.RIGHT:
			camera_3d.global_position = player_pos + Vector3(15, 2, 0)
			camera_3d.look_at(player_pos + Vector3(0, 1, 0), Vector3.UP)
		Perspective.TOP:
			camera_3d.global_position = player_pos + Vector3(0, 20, 0)
			camera_3d.look_at(player_pos, Vector3.BACK)
	
	camera_3d.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera_3d.size = 12.0 # esto para alejarla más
	player.set_dimension_mode(DimensionMode.MODE_2D, current_perspective, _saved_depth)

# salir del modo 2D
func _exit_2d() -> void:
	var data = PERSPECTIVE_DATA[current_perspective] 
	var new_pos = _try_raycast_depth(data)      
	player.global_position = new_pos 
	camera_3d.position = _camera_original_position
	camera_3d.rotation_degrees = _camera_original_rotation
	camera_3d.projection = Camera3D.PROJECTION_PERSPECTIVE      
	current_mode = DimensionMode.MODE_3D
	player.set_dimension_mode(DimensionMode.MODE_3D, current_perspective)

# intento de hacer "crush"
func _try_raycast_depth(data: Dictionary) -> Vector3:
	var space = get_world_3d().direct_space_state
	var origin = player.global_position
	var target = origin + data["dir"] * 100.0

	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [player.get_rid()]

	var result = space.intersect_ray(query)

	if result:
		return result["position"]
		
	var pos = player.global_position

	match data["axis"]:
		"x":
			pos.x = _saved_depth
		"y":
			pos.y = _saved_depth
		"z":
			pos.z = _saved_depth

	return pos


func _process(_delta: float) -> void:
	if current_mode == DimensionMode.MODE_2D:
		_update_2d_camera()

func _update_2d_camera() -> void:
	var player_pos := player.global_position
	match current_perspective:
		Perspective.FRONT:
			camera_3d.global_position = player_pos + Vector3(0, 2, 15)
		Perspective.BACK:
			camera_3d.global_position = player_pos + Vector3(0, 2, -15)
		Perspective.LEFT:
			camera_3d.global_position = player_pos + Vector3(-15, 2, 0)
		Perspective.RIGHT:
			camera_3d.global_position = player_pos + Vector3(15, 2, 0)
		Perspective.TOP:
			camera_3d.global_position = player_pos + Vector3(0, 20, 0)
	
	# para centrar camara en personaje
	var target = player_pos + Vector3(0, 1, 0)
	var up_vec = Vector3.BACK if current_perspective == Perspective.TOP else Vector3.UP
	camera_3d.look_at(target, up_vec)

func _find_entry_plane(data: Dictionary) -> Vector3:
	var space = get_world_3d().direct_space_state
	var origin = player.global_position
	
	var down_target = origin + Vector3(0, -10, 0)
	var down_query = PhysicsRayQueryParameters3D.create(origin, down_target)
	down_query.exclude = [player.get_rid()]
	var down_result = space.intersect_ray(down_query)
	
	if down_result:
		# Usa el Z (o X) del bloque bajo los pies como plano de entrada
		var final_pos = origin
		match data["axis"]:
			"x": final_pos.x = down_result["position"].x
			"y": final_pos.y = down_result["position"].y  
			"z": final_pos.z = down_result["position"].z
		return final_pos
	
	return origin

# funcion que elige la camara con tab
func _choose_smart_perspective() -> void:
	# Obtenemos hacia dónde mira la cámara (Z negativo es adelante en Godot)
	var cam_forward = -camera_3d.global_basis.z
	
	# 1. Prioridad: ¿Estamos mirando muy hacia arriba o muy hacia abajo?
	if abs(cam_forward.y) > 0.7:
		current_perspective = Perspective.TOP
	
	# 2. ¿El jugador mira más hacia los lados (X) o hacia adelante/atrás (Z)?
	elif abs(cam_forward.x) > abs(cam_forward.z):
		# Lógica para X (Izquierda/Derecha)
		if cam_forward.x > 0:
			current_perspective = Perspective.LEFT
		else:
			current_perspective = Perspective.RIGHT
	else:
		# Lógica para Z (Frente/Atrás) corregida:
		# En Godot, cam_forward.z < 0 significa que miras hacia el fondo del escenario
		if cam_forward.z < 0:
			current_perspective = Perspective.FRONT
		else:
			current_perspective = Perspective.BACK
			
	print("[DimensionSystem] Perspectiva inteligente (corregida): ", current_perspective)
