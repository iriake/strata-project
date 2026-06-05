extends PlayerSkin

func idle():
	state_machine.travel("Idle")
	
func move():
	state_machine.travel("Walk")
	
func jump():
	state_machine.travel("Pre_jump")

func fall():
	state_machine.travel("Fall")

func dance():
	state_machine.travel("Dance")
