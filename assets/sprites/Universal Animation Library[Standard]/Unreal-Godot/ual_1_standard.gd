class_name PlayerSkin extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")


func idle():
	state_machine.travel("Idle")
	
func move():
	state_machine.travel("Walk")
	
func fall():
	state_machine.travel("Jump")
	
func jump():
	state_machine.travel("Jump_Start")
	
func crouch_idle():
	state_machine.travel("Crouch_Idle")
	
func crouch_move():
	state_machine.travel("Crouch_Fwd")
