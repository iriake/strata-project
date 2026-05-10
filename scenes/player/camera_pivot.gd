extends Node3D

@export var transition_time := 0.3

var _target_rotation_y := 0.0
var _target_rotation_x := 0.0
var _current_tween: Tween

func _ready() -> void:
	_target_rotation_y = rotation.y
	_target_rotation_x = rotation.x
	
func side_rotation(direction: float):
	if _current_tween:
		_current_tween.kill()
	
	_target_rotation_y += (PI / 2.0) * direction
	
	_start_transition()
	
func set_fixed_view(view: String):
	if _current_tween:
		_current_tween.kill()
	
	match view:
		"top": _target_rotation_x = (PI / 2.0) - 0.1
		"reset": _target_rotation_x = PI / 8.0
	
	_start_transition()
	
func _start_transition():
	_current_tween = create_tween().set_parallel(true)
	_current_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	_current_tween.tween_property(self, "rotation:y", _target_rotation_y, transition_time)
	_current_tween.tween_property(self, "rotation:x", _target_rotation_x, transition_time)
