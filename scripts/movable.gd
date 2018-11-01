extends KinematicBody2D

export (int) var hit
export (int) var SPEED
export (int) var life_max
export (int) var range_attack
export (int) var move_attack

signal hud_life_player_change_sig

var life = life_max
var direction_name = Tools.VEC_SOUTH
var velocity = Vector2(0,0)

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
	
func move():
	move_and_slide(self.velocity)
	
func stop_move():
	self.velocity = Vector2(0,0)
	
func play_animation(var direction, var name_animation, var animation):
	if direction == Tools.VEC_RIGHT || direction == Tools.VEC_RIGHT_NORTH || direction == Tools.VEC_RIGHT_SOUTH:
		animation.set_animation(name_animation + "_right")
	elif direction == Tools.VEC_NORTH || direction == Tools.VEC_NORTH_RIGHT || direction == Tools.VEC_NORTH_LEFT:
		animation.set_animation(name_animation + "_back")
	elif direction == Tools.VEC_LEFT || direction == Tools.VEC_LEFT_NORTH || direction == Tools.VEC_LEFT_SOUTH:
		animation.set_animation(name_animation + "_left")
	elif direction == Tools.VEC_SOUTH || direction == Tools.VEC_SOUTH_RIGHT || direction == Tools.VEC_SOUTH_LEFT:
		animation.set_animation(name_animation + "_front")

func get_animation(var direction, var name_animation):
	if direction == Tools.VEC_RIGHT || direction == Tools.VEC_RIGHT_NORTH || direction == Tools.VEC_RIGHT_SOUTH:
		return name_animation + "_right"
	elif direction == Tools.VEC_NORTH || direction == Tools.VEC_NORTH_RIGHT || direction == Tools.VEC_NORTH_LEFT:
		return name_animation + "_back"
	elif direction == Tools.VEC_LEFT || direction == Tools.VEC_LEFT_NORTH || direction == Tools.VEC_LEFT_SOUTH:
		return name_animation + "_left"
	elif direction == Tools.VEC_SOUTH || direction == Tools.VEC_SOUTH_RIGHT || direction == Tools.VEC_SOUTH_LEFT:
		return name_animation + "_front"
		
func get_collision_position():
	var collision = self.get_node("Collision")
	return self.position + collision.position + collision.shape.extents/2.0