extends "res://scripts/movable.gd"

var player
var direction = Tools.VEC_SOUTH
var bias = 2.0
var CLOSE_DISTANCE_SCALE = 0.2

func _ready():
	self.player = get_node("../Player")
	self.position = self.player.position + self.player.direction_vec
	
func update_position():
	var offset = self.player.position + (self.player.get_node("Trigger/CollisionShape2D").position + self.player.get_node("Trigger/CollisionShape2D").shape.extents/2.0) - self.player.direction_vec * SPEED * CLOSE_DISTANCE_SCALE
	self.position = offset

func _process(delta):
	var offset = self.player.position + (self.player.get_node("Trigger/CollisionShape2D").position + self.player.get_node("Trigger/CollisionShape2D").shape.extents/2.0) - self.player.direction_vec * SPEED * CLOSE_DISTANCE_SCALE
	if self.position.distance_to(offset) < bias:
		stop()
	else:
		var move = (offset - self.position).normalized()
		var velocity = move * self.player.SPEED * self.player.factor_speed
		move_and_slide(velocity)

		#which direction is the player
		if(velocity != Vector2(0,0)):
			self.direction = Tools.get_direction(velocity.normalized())
	#		play_animation(self.direction, "walk")
		
func stop():
	move_and_slide(Vector2(0,0))
#	play_animation(self.direction, "wait")