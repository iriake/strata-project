extends Node

# --- Coleccionables ---
var collectibles_collected: int = 0
var collectibles_total: int = 0

func collect() -> void:
	collectibles_collected += 1
	if collectibles_collected >= collectibles_total:
		EventBus.level_completed.emit()


# --- Estado del nivel ---
func reset() -> void:
	collectibles_collected = 0
	collectibles_total = 0
