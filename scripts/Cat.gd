extends "res://scripts/movable.gd"

var player
var direction = Tools.VEC_SOUTH
var bias = 2.0
var CLOSE_DISTANCE_SCALE = 0.4
var direction_name = Tools.VEC_SOUTH
var velocity = Vector2()

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
		self.velocity = move * self.player.SPEED * self.player.factor_speed
		move_and_slide(self.velocity)

		#which direction is the player
		if(self.velocity != Vector2(0,0)):
			self.direction = Tools.get_direction(self.velocity.normalized())
			self.direction_name = Tools.get_direction(self.velocity.normalized())
			play_animation(self.direction_name, "walk", $AnimatedSprite)
		
func stop():
	move_and_slide(Vector2(0,0))
	play_animation(self.direction_name, "wait", $AnimatedSprite)