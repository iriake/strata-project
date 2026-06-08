## Gestiona la transición del fondo entre 3D (WorldEnvironment/Sky) y 2D (escena parallax).
## Instancia la escena 2D del usuario en un CanvasLayer y calcula el parallax
## manualmente a partir del movimiento de la Camera3D.
class_name BackgroundHandler
extends Node

## Escena de parallax 2D creada por el usuario (con Parallax2D + Sprite2D).
@export var parallax_scene: PackedScene

## Multiplicador global de la intensidad del efecto parallax.
@export var parallax_intensity := 1.0

## Escala de los sprites para que cubran la pantalla (ajustar según resolución y gusto).
@export var sprite_scale := Vector2(3.0, 3.0)

## Color de fondo en modo 2D (negro por defecto).
@export var background_color := Color.BLACK

# --- ESTADO INTERNO ---
var _world_env: WorldEnvironment
var _original_environment: Environment
var _camera_ref: Camera3D
## CanvasLayer que contendrá la escena 2D, renderizado detrás del mundo 3D.
var _canvas_layer: CanvasLayer
## Instancia de la escena parallax del usuario.
var _parallax_instance: Node2D
## Posición del jugador al iniciar el modo 2D (referencia absoluta para el parallax).
var _player_spawn_origin := Vector3.ZERO
## Cache de los Parallax2D y sus scroll_scale para calcular el efecto.
var _parallax_layers: Array[Dictionary] = []


func _ready() -> void:
	await get_tree().process_frame
	_find_world_environment()


func _find_world_environment() -> void:
	_world_env = get_tree().root.find_child("WorldEnvironment", true, false) as WorldEnvironment
	if _world_env:
		print("[BackgroundHandler] WorldEnvironment encontrado: ", _world_env.get_path())
		if _world_env.environment:
			_original_environment = _world_env.environment
			print("[BackgroundHandler] Environment original obtenido con éxito.")
		else:
			printerr("[BackgroundHandler] ERROR: WorldEnvironment no tiene un recurso Environment asignado.")
	else:
		# Fallback al método recursivo manual si find_child falla
		_world_env = _find_node_of_type(get_tree().root, "WorldEnvironment") as WorldEnvironment
		if _world_env:
			print("[BackgroundHandler] WorldEnvironment encontrado mediante fallback: ", _world_env.get_path())
			if _world_env.environment:
				_original_environment = _world_env.environment
		else:
			printerr("[BackgroundHandler] ERROR: No se pudo encontrar ningún nodo WorldEnvironment en el árbol de escenas.")


## Activa el fondo parallax 2D.
func enter_2d_background(camera: Camera3D, camera_pivot: Node3D) -> void:
	if not _world_env:
		_find_world_environment()
	if not _world_env or not _original_environment:
		printerr("[BackgroundHandler] ERROR al entrar en 2D: WorldEnvironment o Environment es nulo.")
		return

	_camera_ref = camera

	# Detectar si es vista superior (top-down) usando la misma fórmula del jugador
	var basis_z = camera_pivot.global_basis.z
	var is_top_down = abs(basis_z.y * 2.0) > 0.9
	
	if is_top_down:
		print("[BackgroundHandler] Vista superior (Top-Down) detectada. Manteniendo fondo 3D original.")
		if _canvas_layer:
			_canvas_layer.visible = false
		return

	# Imprimir diagnósticos detallados sobre el árbol y cámaras
	print("[BackgroundHandler] === DIAGNÓSTICO DE INGRESO 2D ===")
	print("[BackgroundHandler] _world_env: ", _world_env, " (en árbol: ", _world_env.is_inside_tree(), ")")
	if _world_env:
		print("[BackgroundHandler] _world_env environment: ", _world_env.environment)
	print("[BackgroundHandler] camera: ", camera, " (current: ", camera.current, ")")
	print("[BackgroundHandler] camera environment override: ", camera.environment)
	print("[BackgroundHandler] Viewport transparent_bg: ", get_viewport().transparent_bg)
	print("[BackgroundHandler] Buscando otros nodos relevantes:")
	_print_tree_nodes(get_tree().root, "  ")
	print("[BackgroundHandler] ===================================")

	# FIX 2: Capturar el origen del jugador cada vez que se entra en modo 2D,
	# no solo en _ready(), para que el parallax parta desde cero en cada transición.
	var player := get_parent() as Node3D
	if player:
		_player_spawn_origin = player.global_position
	else:
		printerr("[BackgroundHandler] ADVERTENCIA: get_parent() no es Node3D. El parallax no se moverá correctamente.")

	print("[BackgroundHandler] Activando modo 2D. Configurando BG_CANVAS en WorldEnvironment.")

	# 1. Configurar el environment duplicado usando BG_CANVAS
	var env_2d = _original_environment.duplicate()
	env_2d.background_mode = Environment.BG_CANVAS
	env_2d.background_canvas_max_layer = -100
	env_2d.sky = null
	
	# Aplicar el environment al WorldEnvironment y a la cámara
	if _world_env:
		_world_env.environment = env_2d
	camera.environment = env_2d

	# 2. Crear CanvasLayer e instanciar la escena (solo la primera vez)
	if parallax_scene and not _parallax_instance:
		# CanvasLayer con layer negativo (-100) para que se dibuje detrás de otras capas 2D
		_canvas_layer = CanvasLayer.new()
		_canvas_layer.layer = -100
		add_child(_canvas_layer) # Agregado como hijo de este nodo para limpieza automática

		_parallax_instance = parallax_scene.instantiate() as Node2D
		_canvas_layer.add_child(_parallax_instance)

		_cache_parallax_layers()

	if _canvas_layer:
		_canvas_layer.visible = true


## Restaura el fondo 3D.
func exit_2d_background() -> void:
	print("[BackgroundHandler] Restaurando fondo 3D original.")
	
	# Restaurar environments
	if _camera_ref:
		_camera_ref.environment = null
		
	if _world_env:
		_world_env.environment = _original_environment

	if _canvas_layer:
		_canvas_layer.visible = false


## Actualiza el parallax cada frame en modo 2D.
func update_2d_background(camera: Camera3D, _camera_pivot: Node3D) -> void:
	if not _canvas_layer or not _canvas_layer.visible:
		return
	_apply_parallax(camera)


## Cachea las capas Parallax2D y aplica la escala inicial a los Sprite2D.
func _cache_parallax_layers() -> void:
	_parallax_layers.clear()
	if not _parallax_instance:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	_parallax_instance.position = viewport_size / 2.0

	for child in _parallax_instance.get_children():
		if child is Parallax2D:
			var layer_data := {
				"node": child,
				"scroll_scale": child.scroll_scale,
			}
			_parallax_layers.append(layer_data)

			# Desactivar auto-seguimiento de cámara 2D en Parallax2D para evitar conflictos en 3D
			child.ignore_camera_scroll = true

			for sprite in child.get_children():
				if sprite is Sprite2D:
					sprite.scale = sprite_scale
					# Configurar automáticamente repeat_size para el scroll infinito horizontal
					if sprite.texture:
						child.repeat_size.x = sprite.texture.get_size().x * sprite_scale.x


## Aplica el efecto parallax proyectando el movimiento del jugador a offsets 2D.
func _apply_parallax(camera: Camera3D) -> void:
	var player := get_parent() as Node3D
	if not player:
		return
	var player_offset: Vector3 = player.global_position - _player_spawn_origin

	var offset_x: float = camera.global_basis.x.dot(player_offset)
	var offset_y: float = player_offset.y

	var pixels_per_unit := get_viewport().get_visible_rect().size.y / camera.size if camera.projection == Camera3D.PROJECTION_ORTHOGONAL else 50.0

	for layer_data in _parallax_layers:
		var node: Parallax2D = layer_data["node"]
		var scroll: Vector2 = layer_data["scroll_scale"]

		# Usar scroll_offset en vez de position para que Parallax2D haga el tileado/repetición correcto
		node.scroll_offset = Vector2(
			-offset_x * scroll.x * pixels_per_unit * parallax_intensity,
			offset_y * (scroll.y * 0.05) * pixels_per_unit * parallax_intensity
		)


func _find_node_of_type(root: Node, type_name: String) -> Node:
	if root.get_class() == type_name:
		return root
	for child in root.get_children():
		var found = _find_node_of_type(child, type_name)
		if found:
			return found
	return null


func _exit_tree() -> void:
	if _canvas_layer and is_instance_valid(_canvas_layer):
		_canvas_layer.queue_free()


func _print_tree_nodes(node: Node, prefix: String) -> void:
	if node is WorldEnvironment or node is Camera3D:
		var env_info = ""
		if node is WorldEnvironment:
			env_info = " - environment: " + str(node.environment)
		elif node is Camera3D:
			env_info = " - current: " + str(node.current) + " - environment: " + str(node.environment)
		print(prefix, node.name, " (", node.get_class(), ") - path: ", node.get_path(), env_info)
	for child in node.get_children():
		_print_tree_nodes(child, prefix + "  ")
