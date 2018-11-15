extends "res://scripts/movable.gd"

signal enter_in_another_area
signal get_object_signal

var destination = Vector2()
var direction_vec = Vector2(0.0, 1.0)
var factor_speed = 0.0
var touched_bodies = []

func _ready():
	self.life = self.life_max
	self.velocity = Vector2(0,0)
	self.direction_name = Tools.VEC_SOUTH
	self.connect("hud_life_change_sig", $TextureProgress, "set_value")
	self.connect("get_object_signal", $ObjectGetting, "print_object")
	
	$Attack.set_block_signals(true)

func _process(delta):
	move_and_slide(self.velocity + self.velocity_push)
	self.remained_velocity -= 1
	self.velocity_push *= self.damp_push
	if self.remained_velocity == 0:
		self.velocity_push = Vector2(0,0)
	
	#which direction is the player
	if(self.velocity != Vector2(0,0)):
		self.direction_name = Tools.get_direction(self.velocity.normalized())
		play_animation(self.direction_name, "walk", $AnimatedSprite)
		self.direction_vec = self.velocity.normalized()
		$HalfCircle.set_rotation(Vector2(0,-1).angle_to(self.direction_vec))
		if $WalkTimer.is_stopped():
			$WalkTimer.start()
	else:
		$WalkTimer.stop()
	if $AnimationPlayer.current_animation == "attack" && $AnimationPlayer.is_playing():
		for body in $Attack.get_overlapping_bodies():
			if self.touched_bodies.find(body) == -1:
				attack(body)
		
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

func prepare_attack():
	if $AnimationPlayer.current_animation != "attack" || !$AnimationPlayer.is_playing():
		$attack_effects.rotation = Vector2(0,1).angle_to(self.direction_vec)
		#on joue l"animation d'attaque
		attack_animation(self.position, self.position + self.direction_vec * self.velocity * 10, get_animation(self.direction_name, "attack"), "normal")
		$Attack.rotation = Vector2(0,1).angle_to(self.direction_vec)
		$Attack.set_block_signals(false)
	#	var perpendicular_vector = Vector2(-self.direction_vec.y, self.direction_vec.x)
	#	var pos = Vector2(0,0)
	#	var a = pos - (perpendicular_vector * 40) / 2.0
	#	var b = pos + (perpendicular_vector * 40) / 2.0
	#	var vec1 = direction_vec.rotated(PI/5)
	#	var vec2 = direction_vec.rotated(-PI/5)
	#	var c = pos + vec1 * range_attack
	#	var d = pos + vec2 * range_attack
	#	$Attack/CollisionPolygon2D.polygon = [b, a, d, c]
	
	
func attack(var body):
	if body.is_in_group("Enemis"):
		$PunchSound.play()
		var pos_enemi = body.get_collision_position()
		body.decrease_life(self.hit)
		body.move_animation(pos_enemi, pos_enemi + self.direction_vec * self.move_attack, get_animation(body.direction_name, "walk"), 0)
		self.touched_bodies.append(body)
	
func attack_animation(var init_position, new_position, var animation_name, var animation_name2):
	process_move_velocity((new_position - init_position).normalized(), 1000, $AnimationPlayer.get_animation("attack").length, 0.8)
	$AnimationPlayer.get_animation("attack").set_length(RECOVERY_ATTACK_TIME)
	$AnimationPlayer.get_animation("attack").track_set_key_value(1,0, animation_name2)
	$AnimationPlayer.get_animation("attack").track_set_key_value(0,0, animation_name)
	$AnimationPlayer.play("attack")

func move_animation(var init_position, new_position, var animation_name):
	process_move_velocity((new_position - init_position).normalized(), 1000, $AnimationPlayer.get_animation("attack").length, 0.5)
	$AnimationPlayer.get_animation("movement").track_set_key_value(0,0, "touched_front")
	$AnimationPlayer.get_animation("movement").track_set_key_value(0,1, animation_name)
	$AnimationPlayer.play("movement")
	$AnimationPlayer.queue("touched")
	
func get_object(var name):
	$ObjectGetting.play(name)

func _on_AnimationPlayer_animation_finished(anim_name):
	play_animation(self.direction_name, "wait", $AnimatedSprite)
	$AnimatedSprite.playing = true
	self.touched_bodies.clear()
	$Attack.set_block_signals(true)

func _on_WalkTimer_timeout():
#	$StepSound.play()
#	$WalkTimer.set_wait_time(1.0 - self.factor_speed)
	pass

func _on_ObjectGetting_animation_finished():
	$ObjectGetting.play("default")

func _on_attack_effects_animation_finished():
	$attack_effects.set_animation("nothing")
