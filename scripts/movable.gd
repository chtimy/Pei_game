extends KinematicBody2D

export (int) var hit
export (int) var SPEED
export (int) var life_max
export (int) var range_attack
export (int) var move_attack

signal hud_life_change_sig
signal character_dead_signal

var life = life_max
var direction_name = Tools.VEC_SOUTH
var velocity = Vector2(0,0)

var velocity_push = Vector2(0, 0)
var damp_push = 1.0
var remained_velocity = 0

var animation_move_velocity

func decrease_life(var value):
	self.life = clamp(self.life - value, 0, self.life_max)

func increase_life(var value):
	self.life = clamp(self.life + value, 0, self.life_max)
	
func die():
	emit_signal("character_dead_signal", self)
	
func animation_move(var factor = 1.0):
	move_and_slide(animation_move_velocity * factor)
	
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
	return self.position + get_collision_center()
	
func get_collision_center():
	var collision = self.get_node("Collision")
	return collision.position + collision.shape.extents/2.0
	
func process_move_velocity(var velocity, var factor, var seconds, var damp = 1.0):
	self.velocity_push = velocity * factor
	self.remained_velocity = int(seconds / get_process_delta_time())
	self.damp_push = damp