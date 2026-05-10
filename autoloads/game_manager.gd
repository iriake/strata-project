extends Node

var collectibles_collected: int = 0
var collectibles_total: int = 0
var player_position_3d: Vector3 = Vector3.ZERO
var saved_depth: float = 0.0
var active_perspective: int = 0  
var came_from_2d: bool = false
var is_in_2d_mode: bool = false

func collect() -> void:
	collectibles_collected += 1
	if collectibles_collected >= collectibles_total:
		EventBus.level_completed.emit()
