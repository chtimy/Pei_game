extends Node2D

func pause():
	self.set_visible(false)
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	set_block_signals(true)
	
	
func play():
	self.set_visible(true)