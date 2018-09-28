extends KinematicBody2D

export (int) var hit
export (int) var SPEED
export (int) var life

func decrease_life(var value):
	self.life -= value
	if self.life <= 0:
		self.life = 0
		die()
	
func freeze():
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	
func unfreeze():
	set_process(true)
	set_process_input(true)
	set_physics_process(true)

func play_animation(var direction, var name_animation):
	if direction == Tools.VEC_RIGHT:
		$AnimatedSprite.set_animation(name_animation + "_right")
	elif direction == Tools.VEC_NORTH_RIGHT:
		pass
	elif direction == Tools.VEC_NORTH:
		$AnimatedSprite.set_animation(name_animation + "_back")
	elif direction == Tools.VEC_NORTH_LEFT:
		pass
	elif direction == Tools.VEC_LEFT:
		$AnimatedSprite.set_animation(name_animation + "_left")
	elif direction == Tools.VEC_SOUTH_LEFT:
		pass
	elif direction == Tools.VEC_SOUTH:
		$AnimatedSprite.set_animation(name_animation + "_front")
	elif direction == Tools.VEC_SOUTH_RIGHT: