extends KinematicBody2D

signal delete_object_from_Player
signal player_change_life
signal enter_in_another_area
signal player_died

var hit = 40
var last_position = Vector2()
export (int) var SPEED
var life = 75
var destination = Vector2()
var direction = Vector2(1, 0)

var velocity = Vector2()

func _ready():
	self.velocity = Vector2(0,0)
	self.destination = self.position

func _process(delta):
#	move_and_collide(velocity*delta)
	move_and_slide(velocity)
	
	if(velocity != Vector2(0,0)):
		self.direction = velocity.normalized()
		if direction.angle_to(Vector2(1,0)) <= PI/4.0 && direction.angle_to(Vector2(1,0)) >= -PI/4.0:
			direction = Vector2(1,0)
		if direction.angle_to(Vector2(-1,0)) <= PI/4.0 && direction.angle_to(Vector2(-1,0)) >= -PI/4.0:
			direction = Vector2(-1,0)
		if direction.angle_to(Vector2(0,1)) <= PI/4.0 && direction.angle_to(Vector2(0,1)) >= -PI/4.0:
			direction = Vector2(0,1)
		if direction.angle_to(Vector2(0,-1)) <= PI/4.0 && direction.angle_to(Vector2(0,-1)) >= -PI/4.0:
			direction = Vector2(0,-1)

	if self.position.distance_to(self.destination) < 5:
		velocity = Vector2(0,0)
		
func stop():
	velocity = Vector2(0,0)
	if self.direction == Vector2(1,0):
		$AnimatedSprite.set_animation("wait_right")
	elif self.direction == Vector2(0,-1):
		$AnimatedSprite.set_animation("wait_back")
	elif self.direction == Vector2(0,1):
		$AnimatedSprite.set_animation("wait_front")
	elif self.direction == Vector2(-1,0):
		$AnimatedSprite.set_animation("wait_left")
	
func set_move(var move, var factor_speed):
	factor_speed = clamp(factor_speed, 0.0, 1.0)
	var vec = move.normalized()
	if vec.angle_to(Vector2(1,0)) < PI/4.0 && vec.angle_to(Vector2(1,0)) > -PI/4.0:
		$AnimatedSprite.set_animation("walk_right")
	elif vec.angle_to(Vector2(0,-1)) < PI/4.0 && vec.angle_to(Vector2(0,-1)) > -PI/4.0:
		$AnimatedSprite.set_animation("walk_up")
	elif vec.angle_to(Vector2(0,1)) < PI/4.0 && vec.angle_to(Vector2(0,1)) > -PI/4.0:
		$AnimatedSprite.set_animation("walk_down")
	elif vec.angle_to(Vector2(-1,0)) < PI/4.0 && vec.angle_to(Vector2(-1,0)) > -PI/4.0:
		$AnimatedSprite.set_animation("walk_left")
	velocity = move * SPEED * factor_speed

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
	
func attack():
	print(self.direction)
	if self.direction == Vector2(1,0):
		$AnimatedSprite.set_animation("attack_right")
		for area in $attack_right.get_overlapping_areas():
			print(area.get_node("..").get_groups())
			if area.get_node("..").is_in_group("Enemis"):
				area.get_node("..").take_damages(self.hit)
	if self.direction == Vector2(-1,0):
		$AnimatedSprite.set_animation("attack_left")
		for area in $attack_left.get_overlapping_areas():
			print(area.get_node("..").get_groups())
			if area.get_node("..").is_in_group("Enemis"):
				area.get_node("..").take_damages(self.hit)
	if self.direction == Vector2(0,1):
		$AnimatedSprite.set_animation("attack_front")
		for area in $attack_down.get_overlapping_areas():
			print(area.get_node("..").get_groups())
			if area.get_node("..").is_in_group("Enemis"):
				area.get_node("..").take_damages(self.hit)
	if self.direction == Vector2(0,-1):
		$AnimatedSprite.set_animation("attack_back")
		for area in $attack_up.get_overlapping_areas():
			print(area.get_node("..").get_groups())
			if area.get_node("..").is_in_group("Enemis"):
				area.get_node("..").take_damages(self.hit)


func _on_AnimatedSprite_animation_finished():
	var name_animation = $AnimatedSprite.animation
	var regex = RegEx.new()
	regex.compile("_[a-z]*")
	var result1 = regex.search(name_animation)
	regex.compile("[a-z]*_")
	var result2 = regex.search(name_animation)
	if result1 && result2:
		if result2.get_string() == "attack_":
			$AnimatedSprite.play("wait"+result1.get_string())


func collision(area):
	print(area)
	print("collision")
