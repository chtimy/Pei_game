extends Node2D

signal delete_object_from_Player
signal player_change_life
signal enter_in_another_area
signal player_died

var hit = 40
var last_position = Vector2()
export (int) var SPEED
var life = 75
var destination = Vector2()

var velocity = Vector2()

func _ready():
	self.velocity = Vector2(0,0)
	self.destination = self.position

func _physics_process(delta):
	move_and_collide(velocity*delta)
	
	if self.position.distance_to(self.destination) < 5:
		velocity = Vector2(0,0)
	
func set_move(var move):
	velocity = move * SPEED

#	var screenSize = get_viewport().get_size()
#	var speedVector = Vector2()
#
#	if speedVector.length() > 0:
#		speedVector = speedVector.normalized() * SPEED
#
#	position += speedVector * delta
#	position.x = clamp(position.x, 0, screenSize.x)
#	position.y = clamp(position.y, 0, screenSize.y)

func die():
	print("dead")
	emit_signal("player_died")
	
func decrease_life(var value):
	self.life -= value
	if self.life <= 0:
		self.life = 0
		die()
	emit_signal("player_change_life", life)

func _on_Shape_area_entered(area):
	var selectable = area.get_node("..")
	if selectable.is_in_group("Bullets"):
		decrease_life(selectable.hit)
		emit_signal("delete_object_from_Player", selectable)
	elif selectable.is_in_group("Movables"):
		emit_signal("enter_in_another_area", area)
#		var dir = (self.last_position - self.position).normalized
		
		area.get_node("..").enter_in_another_area($Shape)
		
func freeze():
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	
func unfreeze():
	set_process(true)
	set_process_input(true)
	set_physics_process(true)
