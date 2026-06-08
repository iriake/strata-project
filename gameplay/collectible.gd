extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	var player = body as Player2
	if player:
		monitoring = false
		get_tree().reload_current_scene()
