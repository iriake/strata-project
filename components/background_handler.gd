## Gestiona la transición del fondo entre 3D (WorldEnvironment/Sky) y 2D (escena parallax).
## Instancia la escena 2D del usuario en un CanvasLayer y calcula el parallax
## manualmente a partir del movimiento de la Camera3D.
class_name BackgroundHandler
extends Node

## Escena de parallax 2D creada por el usuario (con Parallax2D + Sprite2D).
@export var parallax_scene: PackedScene

## Escena de parallax 2D específica para la vista superior (top-down).
@export var parallax_scene_topdown: PackedScene

## Multiplicador global de la intensidad del efecto parallax.
@export var parallax_intensity := 1.0

## Escala de los sprites para que cubran la pantalla (ajustar según resolución y gusto).
@export var sprite_scale := Vector2(3.0, 3.0)

## Color de fondo en modo 2D (negro por defecto).
@export var background_color := Color.BLACK

## Desviación de ángulo (en grados) para alinear el fondo 2D con el panorama 3D.
@export var background_rotation_offset := 0.0

# --- ESTADO INTERNO ---
var _world_env: WorldEnvironment
var _original_environment: Environment
## Cache del environment 2D generado a partir del original 3D.
var _env_2d: Environment
var _camera_ref: Camera3D
## CanvasLayer que contendrá la escena 2D, renderizado detrás del mundo 3D.
var _canvas_layer: CanvasLayer
## Instancia de la escena parallax lateral.
var _parallax_instance_side: Node2D
## Instancia de la escena parallax cenital (top-down).
var _parallax_instance_topdown: Node2D
## Indica si la transición actual es vista superior (top-down).
var _is_top_down := false
## Posición del jugador al iniciar el modo 2D (referencia absoluta para el parallax).
var _player_spawn_origin := Vector3.ZERO
## Cache de los Parallax2D y sus scroll_scale para calcular el efecto.
var _parallax_layers: Array[Dictionary] = []


func _ready() -> void:
	await get_tree().process_frame
	_find_world_environment()
	
	# Conectarse a las señales del padre si tiene dimension_changed
	var parent = get_parent()
	if parent and parent.has_signal("dimension_changed"):
		parent.dimension_changed.connect(_on_parent_dimension_changed)


func _on_parent_dimension_changed(to_2d: bool, camera: Camera3D, camera_pivot: Node3D) -> void:
	if to_2d:
		enter_2d_background(camera, camera_pivot)
	else:
		exit_2d_background()


func _find_world_environment() -> void:
	_world_env = get_tree().root.find_child("WorldEnvironment", true, false) as WorldEnvironment
	if _world_env:
		print("[BackgroundHandler] WorldEnvironment encontrado: ", _world_env.get_path())
		if _world_env.environment:
			_original_environment = _world_env.environment
			_create_2d_environment_cache()
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
				_create_2d_environment_cache()
		else:
			printerr("[BackgroundHandler] ERROR: No se pudo encontrar ningún nodo WorldEnvironment en el árbol de escenas.")


func _create_2d_environment_cache() -> void:
	if _original_environment and not _env_2d:
		_env_2d = _original_environment.duplicate()
		_env_2d.background_mode = Environment.BG_CANVAS
		_env_2d.background_canvas_max_layer = -100
		_env_2d.sky = null
		print("[BackgroundHandler] Environment 2D duplicado y guardado en caché.")


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
	_is_top_down = abs(basis_z.y * 2.0) > 0.9

	print("[BackgroundHandler] Activando modo 2D. Vista cenital: ", _is_top_down)

	if _is_top_down:
		print("[BackgroundHandler] Vista superior (Top-Down) detectada. Manteniendo entorno 3D original y ocultando 2D.")
		if _world_env:
			_world_env.environment = _original_environment
		camera.environment = null
		if _canvas_layer:
			_canvas_layer.visible = false
		return

	if not _env_2d:
		_create_2d_environment_cache()

	var target_scene = parallax_scene

	# 1. Configurar el environment duplicado
	if _env_2d:
		if target_scene:
			_env_2d.background_mode = Environment.BG_CANVAS
		else:
			_env_2d.background_mode = Environment.BG_COLOR
			_env_2d.background_color = background_color
		
		if _world_env:
			_world_env.environment = _env_2d
		camera.environment = _env_2d

	# FIX 2: Capturar el origen del jugador cada vez que se entra en modo 2D,
	# no solo en _ready(), para que el parallax parta desde cero en cada transición.
	var player := get_parent() as Node3D
	if player:
		_player_spawn_origin = player.global_position
	else:
		printerr("[BackgroundHandler] ADVERTENCIA: get_parent() no es Node3D. El parallax no se moverá correctamente.")

	# 2. Crear CanvasLayer e instanciar escenas
	if not _canvas_layer:
		_canvas_layer = CanvasLayer.new()
		_canvas_layer.layer = -100
		add_child(_canvas_layer)

	if parallax_scene and not _parallax_instance_side:
		_parallax_instance_side = parallax_scene.instantiate() as Node2D
		_canvas_layer.add_child(_parallax_instance_side)
		_parallax_instance_side.visible = false

	if parallax_scene_topdown and not _parallax_instance_topdown:
		_parallax_instance_topdown = parallax_scene_topdown.instantiate() as Node2D
		_canvas_layer.add_child(_parallax_instance_topdown)
		_parallax_instance_topdown.visible = false

	# Activar la instancia correcta y ocultar la otra
	if _parallax_instance_side:
		_parallax_instance_side.visible = (target_scene == parallax_scene)
	if _parallax_instance_topdown:
		_parallax_instance_topdown.visible = (target_scene == parallax_scene_topdown)

	var active_instance = _parallax_instance_topdown if (_is_top_down and _parallax_instance_topdown) else _parallax_instance_side
	_cache_parallax_layers(active_instance)

	if _canvas_layer:
		_canvas_layer.visible = (active_instance != null)


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


func _process(_delta: float) -> void:
	if _canvas_layer and _canvas_layer.visible and is_instance_valid(_camera_ref):
		_apply_parallax(_camera_ref)


## Cachea las capas Parallax2D y aplica la escala inicial a los Sprite2D.
func _cache_parallax_layers(instance: Node2D) -> void:
	_parallax_layers.clear()
	if not instance:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	instance.position = viewport_size / 2.0

	for child in instance.get_children():
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
					# Asegurar que el pixel art se vea nítido (Nearest texture filtering)
					sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
					# Configurar automáticamente repeat_size para el scroll infinito
					if sprite.texture:
						child.repeat_size.x = sprite.texture.get_size().x * sprite_scale.x
						if _is_top_down:
							child.repeat_size.y = sprite.texture.get_size().y * sprite_scale.y


## Aplica el efecto parallax proyectando el movimiento del jugador y la rotación de la cámara.
func _apply_parallax(camera: Camera3D) -> void:
	var player := get_parent() as Node3D
	if not player:
		return
	var player_offset: Vector3 = player.global_position - _player_spawn_origin

	var offset_x: float = camera.global_basis.x.dot(player_offset)
	var offset_y: float = camera.global_basis.y.dot(player_offset)

	var pixels_per_unit := get_viewport().get_visible_rect().size.y / camera.size if camera.projection == Camera3D.PROJECTION_ORTHOGONAL else 50.0

	var y_multiplier = 1.0 if _is_top_down else 0.05
	
	# Ángulo yaw de la cámara (Y) para desplazar el fondo lateralmente
	var phi := camera.global_rotation.y - PI + deg_to_rad(background_rotation_offset)

	for layer_data in _parallax_layers:
		var node: Parallax2D = layer_data["node"]
		var scroll: Vector2 = layer_data["scroll_scale"]

		# Calcular offset por rotación de cámara en vista lateral
		var rot_offset := 0.0
		if not _is_top_down and node.repeat_size.x > 0.0:
			rot_offset = phi * (node.repeat_size.x / (2.0 * PI))

		# Usar scroll_offset en vez de position para que Parallax2D haga el tileado/repetición correcto
		node.scroll_offset = Vector2(
			-offset_x * scroll.x * pixels_per_unit * parallax_intensity + rot_offset,
			offset_y * scroll.y * y_multiplier * pixels_per_unit * parallax_intensity
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
