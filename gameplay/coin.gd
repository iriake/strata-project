extends Area2D

#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
#	body_entered.connect(_on_body_entered)
	pass

func _on_body_entered(body: Node2D) -> void:
#	var player: Player = body as Player
#	if player:
#		monitoring = false
#		Game.coins += 1
#		audio_stream_player.play()
#		animated_sprite_2d.play("pick_up")
#		await animated_sprite_2d.animation_finished
#		queue_free()
	pass		
