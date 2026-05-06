extends Control

@export var speed: int = 100
var scrolling: bool = false

@onready var rich_text_label: RichTextLabel = $RichTextLabel

var last_value: float = 0

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	scrolling = true


func _process(delta: float) -> void:
	if scrolling:
		var scroll_bar: VScrollBar = rich_text_label.get_v_scroll_bar()
		scroll_bar.value += delta * speed
		if scroll_bar.value == last_value:
			scrolling = false
			finish_scrolling()
		last_value = scroll_bar.value


func finish_scrolling() -> void:
	await get_tree().create_timer(2).timeout
	LevelManager.main_menu()
