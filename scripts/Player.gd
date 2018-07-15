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
	if velocity == Vector2(0,0):
		$AnimatedSprite.set_animation("front")
	if self.position.distance_to(self.destination) < 5:
		velocity = Vector2(0,0)
		
func stop():
	velocity = Vector2(0,0)
	
func set_move(var move):
	var vec = move.normalized()
	if vec.angle_to(Vector2(1,0)) < PI/4.0 && vec.angle_to(Vector2(1,0)) > -PI/4.0:
		$AnimatedSprite.set_animation("walk_right")
	elif vec.angle_to(Vector2(0,-1)) < PI/4.0 && vec.angle_to(Vector2(0,-1)) > -PI/4.0:
		$AnimatedSprite.set_animation("walk_up")
	elif vec.angle_to(Vector2(0,1)) < PI/4.0 && vec.angle_to(Vector2(0,1)) > -PI/4.0:
		$AnimatedSprite.set_animation("walk_down")
	elif vec.angle_to(Vector2(-1,0)) < PI/4.0 && vec.angle_to(Vector2(-1,0)) > -PI/4.0:
		$AnimatedSprite.set_animation("walk_left")
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
	
#func attack():
#	for enemi in get_node("../Enemis").get_children():
#		if enemi.get_node("shape/zona").
		


func _on_TouchScreenButton_pressed():
#	attack()
	print("test")
	pass # replace with function body
