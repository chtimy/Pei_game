extends "res://scripts/movable.gd"

signal enter_in_another_area
signal get_object_signal

var destination = Vector2()
var direction_vec = Vector2(0.0, 0.0)
var factor_speed = 0.0

func _ready():
	self.life = self.life_max
	self.velocity = Vector2(0,0)
	self.direction_name = Tools.VEC_SOUTH
	self.connect("hud_life_change_sig", $TextureProgress, "set_value")
	self.connect("get_object_signal", $ObjectGetting, "print_object")

func _process(delta):
	move_and_slide(self.velocity)
	
	#which direction is the player
	if(self.velocity != Vector2(0,0)):
		self.direction_name = Tools.get_direction(self.velocity.normalized())
		play_animation(self.direction_name, "walk", $AnimatedSprite)
		self.direction_vec = self.velocity.normalized()
		if $WalkTimer.is_stopped():
			$WalkTimer.start()
	else:
		$WalkTimer.stop()
		
func stop():
	.stop_move()
	play_animation(self.direction_name, "wait", $AnimatedSprite)
	
func set_move(var move, var factor_speed):
	self.factor_speed = factor_speed
	self.velocity = move * SPEED * self.factor_speed

func decrease_life(var value):
	#play_animation(self.direction, "touched")
	.decrease_life(value)
	emit_signal("hud_life_change_sig", (float(life)/life_max) * 100)
	if self.life == 0:
		die()

func increase_life(var value):
	.increase_life(value)
	emit_signal("hud_life_change_sig", (float(life)/life_max) * 100)

func attack_on():
	$attack_effects.rotation = Vector2(0,1).angle_to(self.direction_vec)
	#on joue l"animation d'attaque
	attack_animation(self.position, self.position + self.direction_vec * self.move_attack, get_animation(self.direction_name, "attack"), "normal")
	$PunchSound.play()

	var bodies = $View.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemis"):
			var pos_enemi = body.get_collision_position()
			var vec = (pos_enemi - get_collision_position()).normalized()
#			var dir_player = Tools.get_direction_value(self.direction_name)
			var angle = vec.angle_to(self.direction_vec)
			if angle <= PI/4.0 || angle >= -PI/4.0:
				body.decrease_life(self.hit)
				body.move_animation(self.direction_vec, self.move_attack, get_animation(body.direction_name, "walk"), 0)
	
func attack_animation(var init_position, new_position, var animation_name, var animation_name2):
	$AnimationPlayer.get_animation("attack").track_set_key_value(0,0, init_position)
	$AnimationPlayer.get_animation("attack").track_set_key_value(0,1, new_position)
	$AnimationPlayer.get_animation("attack").track_set_key_value(1,0, animation_name)
	$AnimationPlayer.get_animation("attack").track_set_key_value(2,0, true)
	$AnimationPlayer.get_animation("attack").track_set_key_value(3,0, animation_name2)
	$AnimationPlayer.get_animation("attack").track_set_key_value(4,0, true)
	$AnimationPlayer.get_animation("attack").track_set_key_value(4,1, false)
	$AnimationPlayer.play("attack")

func move_animation(var init_position, new_position, var animation_name):
	$AnimationPlayer.get_animation("movement").track_set_key_value(0,0, init_position)
	$AnimationPlayer.get_animation("movement").track_set_key_value(0,1, new_position)
	$AnimationPlayer.get_animation("movement").track_set_key_value(1,0, "touched_front")
	$AnimationPlayer.get_animation("movement").track_set_key_value(1,1, animation_name)
	$AnimationPlayer.get_animation("movement").track_set_key_value(2,0, true)
	$AnimationPlayer.play("movement")
	$AnimationPlayer.queue("touched")
	
func get_object(var name):
	$ObjectGetting.play(name)

func _on_AnimationPlayer_animation_finished(anim_name):
	play_animation(self.direction_name, "wait", $AnimatedSprite)
	$AnimatedSprite.playing = true

func _on_WalkTimer_timeout():
	$StepSound.play()


func _on_ObjectGetting_animation_finished():
	$ObjectGetting.play("default")

