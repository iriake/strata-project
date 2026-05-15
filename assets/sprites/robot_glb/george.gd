extends PlayerSkin

func idle():
	state_machine.travel("Idle")
	
func move():
	state_machine.travel("Walk")
	
func jump():
	state_machine.travel("Jump")

func dance():
	state_machine.travel("Dance")
