extends Node3D


@onready var animation_tree: AnimationTree = $AnimationTreeMini
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")

func idle():
	state_machine.travel("Robot_Idle")
	
func move():
	state_machine.travel("Robot_Walking")
	
func jump():
	state_machine.travel("Robot_PreJump")

func fall():
	state_machine.travel("Robot_Fall")

func dance():
	state_machine.travel("Robot_Dance")
