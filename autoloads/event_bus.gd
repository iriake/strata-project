extends Node

# --- Dimension ---
signal dimension_changed(new_dimension: String)  # "2D" | "3D"

# --- Player ---
signal player_died()

# --- Level ---
signal level_completed()

# --- Objects ---
signal object_interacted(object_id: String)
