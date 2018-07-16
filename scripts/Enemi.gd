extends Node2D

signal shoot_toward
signal touched_from_enemi
signal drop_clue
signal enemi_die

export (PackedScene) var blaster_shoot_scene

var last_position
var target
var direction = Vector2()
var time = 0
var life = 100
var SPEED = 50

var velocity = Vector2(0,0)

func set_clue(var clue):
	self.clue = clue

func _ready():
	self.connect("shoot_toward", get_node(".."), "shoot_bullet_from")
	self.connect("touched_from_enemi", get_node(".."), "on_touched_enemi")
	self.connect("drop_clue", get_node("../Password/Terminal"), "active_letter")
	self.connect("enemi_die", get_node(".."), "delete_object")
	randomize()
	
func _physics_process(delta):
	move_and_collide(velocity * delta)
	time += 1
	if time > 100:
		velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * SPEED
		time = 0
	
func set_move(var move):
	velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * SPEED

func _on_view_area_entered(area):
	var selectable = area.get_node("..")
	if selectable.is_in_group("Player"):
		self.target = selectable
		$ShootLoopTimer.start()

func _on_view_area_exited(area):
	var selectable = area.get_node("..")
	if selectable.is_in_group("Player"):
		target = null
		$ShootLoopTimer.stop()

func shoot_on():
	var bullet = blaster_shoot_scene.instance()
	bullet.add_to_group("Bullets")
	bullet.direction = Vector2(1, 0)
	bullet.target = "Player"
	bullet.hit = 5
	bullet.position = self.position
	emit_signal("shoot_toward", bullet)
	bullet = blaster_shoot_scene.instance()
	bullet.add_to_group("Bullets")
	bullet.direction = Vector2(-1, 0)
	bullet.target = "Player"
	bullet.hit = 5
	bullet.position = self.position
	emit_signal("shoot_toward", bullet)
	bullet = blaster_shoot_scene.instance()
	bullet.add_to_group("Bullets")
	bullet.direction = Vector2(0, 1)
	bullet.target = "Player"
	bullet.hit = 5
	bullet.position = self.position
	emit_signal("shoot_toward", bullet)
	bullet = blaster_shoot_scene.instance()
	bullet.add_to_group("Bullets")
	bullet.direction = Vector2(0, -1)
	bullet.target = "Player"
	bullet.hit = 5
	bullet.position = self.position
	emit_signal("shoot_toward", bullet)
		
func _on_ShootLoopTimer_timeout():
	shoot_on()
	
#func _process(delta):
#	self.last_position = self.position
#	self.position += direction
#	if time % 200 == 0:
#		direction = Vector2(rand_range(-1,1), rand_range(-1,1))
#		time = 0
#	time += 1
	
func die():
	emit_signal("drop_clue", self.clue)
	emit_signal("enemi_die", self)

func take_damages(var damages):
	self.life -= damages
	if self.life < 50:
		die()
	$ShootLoopTimer.stop()
	$ShootLoopTimer.start()
	emit_signal("touched_from_enemi", $shape)

func enter_in_another_area(var shape):
	var dir = -(shape.get_node("..").position - self.position).normalized()
	var angle = rand_range(-PI/2, PI/2)
	self.velocity = dir.rotated(angle) * SPEED
	
func freeze():
	set_process(false)
	set_process_input(false)
	set_physics_process(false)
	set_block_signals(true)
	
func unfreeze():
	set_process(true)
	set_process_input(true)
	set_physics_process(true)
	set_block_signals(false)