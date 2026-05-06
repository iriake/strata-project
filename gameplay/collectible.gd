extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	var player = body as Player
	if player:
		monitoring = false
		# TODO: notificar al GameManager o EventBus
		# GameManager.collectibles += 1
		queue_free()
