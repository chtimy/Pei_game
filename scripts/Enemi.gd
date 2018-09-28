extends "res://scripts/movable.gd"

signal shoot_toward
signal touched_from_enemi
signal enemi_died_sig

export (PackedScene) var blaster_shoot_scene
export (int) var range_attack
var target = {"target": null, "position" : Vector2(0,0), "is_visible" : false}
var direction = Vector2()
var time = 0

var velocity = Vector2(0,0)

func set_clue(var clue):
	self.clue = clue

func _ready():
	self.connect("touched_from_enemi", get_tree().root.get_node("Game"), "on_touched_enemi")
	self.connect("enemi_died_sig", get_node(".."), "enemi_killed")
	
	randomize()
	$ShootLoopTimer.one_shot = true
	
	
func _process(delta):
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
		self.target.object = selectable
		self.target.position = selectable.position + selectable.get_node("Collision").position + selectable.get_node("Collision").shape.extents/2.0
		self.target.is_visible = true
		$ShootLoopTimer.start()
		set_process(false)

func _on_view_area_exited(area):
	var selectable = area.get_node("..")
	if selectable.is_in_group("Player"):
		self.target.is_visible = false
		set_process(true)

func attack_on():
	var old_vec = (self.target.position - self.position).normalized()
	var direction = Tools.get_direction(old_vec)
#	play_animation(direction, "attack")
	var new_vec = (self.target.object.position - self.position).normalized()
	var direction2 = Tools.get_direction(new_vec)
	if(direction == direction2):
		self.target.object.take_damages(self.hit)
	
	var object = self.target.object
	self.target.position = object.position + object.get_node("Collision").position + object.get_node("Collision").shape.extents/2.0

		
func _on_ShootLoopTimer_timeout():
	self.target.last_position = self.target.object.position
	attack_on()
	if self.target.is_visible:
		$ShootLoopTimer.start()
	
func die():
	emit_signal("enemi_died_sig", self)

func take_damages(var value):
	#animation touché
	decrease_life(value)
	$ShootLoopTimer.stop()
	$ShootLoopTimer.start()
#	emit_signal("touched_from_enemi", $shape)

func decrease_life(var value):
	self.life -= value
	if self.life <= 0:
		self.life = 0
		die()

func enter_in_another_area(var shape):
	var dir = -(shape.get_node("..").position - self.position).normalized()
	var angle = rand_range(-PI/2, PI/2)
	self.velocity = dir.rotated(angle) * SPEED
	
func freeze():
	set_process(false)
	set_process_input(false)
	set_block_signals(true)
	
func unfreeze():
	set_process(true)
	set_process_input(true)
	set_block_signals(false)