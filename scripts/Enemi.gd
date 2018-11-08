extends "res://scripts/movable.gd"

signal touched_from_enemi
signal enemi_died_sig
signal mvt_animation_finished


enum STATE{WALK, ANIMATION, NOTHING}

var target = {"target": null, "position" : Vector2(0,0), "is_visible" : false}
var time = 0
var regex
var state = WALK

func _ready():
	randomize()
	
	self.regex = RegEx.new()
	self.regex.compile("[a-z]*")
	
	self.life = self.life_max
	self.direction_name = Tools.VEC_LEFT
	
	self.connect("touched_from_enemi", get_tree().root.get_node("Game"), "on_touched_enemi")
	self.connect("hud_life_change_sig", $TextureProgress, "set_value")
	self.connect("character_dead_signal", get_node(".."), "character_dead")
	
	$ShootLoopTimer.set_one_shot(true)
	
func _process(delta):
	if state == WALK:
		move_and_slide(velocity)
		time += 1
		if time > 100:
			set_move(Vector2(rand_range(-1, 1), rand_range(-1, 1)), 1)
			time = 0
		if(self.velocity != Vector2(0,0)):
			self.direction_name = Tools.get_direction(self.velocity.normalized())
			play_animation(self.direction_name, "walk", $AnimatedSprite)
	elif state == ANIMATION:
		pass
#		move_and_slide(self.velocity)
#		self.velocity -= self.velocity * 0.1
#		if self.velocity.abs() < Vector2(0.1,0.1):
#			emit_signal("mvt_animation_finished")

		
func set_move(var move, var factor_speed):
	self.velocity = move.normalized() * SPEED * factor_speed

func _on_View_body_entered(body):
	if body.get_name() == "Player":
		if $ShootLoopTimer.is_stopped():
			self.target.body = body
			self.target.old_position = body.get_collision_position()
			#lancement du timer pour l'attaque
			$ShootLoopTimer.start()
			#définition de la direction pour l'animation
			self.direction_name = Tools.get_direction((self.target.old_position - get_collision_position()).normalized())
			#on joue l'animation pour la préparation de l'attaque
			play_animation(self.direction_name, "prepare_attack", $AnimatedSprite)
			#on désactive le process afin que l'ennemi s'arête
			self.state = NOTHING

func attack_on():
	#play_animation(self.direction_name, "attack", $AnimatedSprite)
	#calcul si le joueur est toujours dans la zone d'attaque de l'ennemi
	var current_position = get_collision_position()
	var enemi_current_position = self.target.body.get_collision_position()
	var old_vec = (self.target.old_position - current_position).normalized()
	var new_vec = (enemi_current_position - current_position).normalized()
	
	#on joue l"animation d'attaque
	move_animation(self.position, self.position + old_vec * self.move_attack, get_animation(self.direction_name, "attack"))
	
	#check si çà touche
	if object_inside_attack_area(old_vec, current_position, enemi_current_position):
		self.target.body.decrease_life(self.hit)
		self.target.body.move_animation(self.target.body.position, self.target.body.position + old_vec * self.move_attack, get_animation(self.target.body.direction_name, "wait"))
		
func object_inside_attack_area(var vector_attack, var current_position, var object_position):
	var perpendiculaire_vector = Vector2(vector_attack.y, -vector_attack.x)
	var largeur = 50
	var longueur = 96
	var b = current_position + (perpendiculaire_vector * largeur) / 2.0
	var a = current_position - (perpendiculaire_vector * largeur) / 2.0
	var c = b + vector_attack * longueur
	var d = a + vector_attack * longueur
#	print("a : ", a, " b: ", b, " c: ", c, " d: ", d, " position", object_position, " vector_attack*longueur", vector_attack * longueur, " perpendiculaire_vector * largeur: ", perpendiculaire_vector * largeur, " vector_attack: ", vector_attack, " perpendiculaire_vctor: ", perpendiculaire_vector)
#	print("triangle 1 : ", Tools.point_is_inside_triangle(object_position, a, b, c) , " triangle 2: ", Tools.point_is_inside_triangle(object_position, a, d, c))
	if Tools.point_is_inside_triangle(object_position, a, b, c) || Tools.point_is_inside_triangle(object_position, a, d, c):
		return true
	return false

func move_animation(var init_position, new_position, var animation_name):
	$AnimationPlayer.get_animation("movement").track_set_key_value(0,0, init_position)
	$AnimationPlayer.get_animation("movement").track_set_key_value(0,1, new_position)
	$AnimationPlayer.get_animation("movement").track_set_key_value(1,0, animation_name)
	$AnimationPlayer.get_animation("movement").track_set_key_value(2,0, true)
	$AnimationPlayer.play("movement")

func _on_ShootLoopTimer_timeout():
	#quand le timer s'arrête, l'ennemi attaque
	attack_on()
	var bodies = $View.get_overlapping_bodies()
	for body in bodies:
		if body.get_name() == "Player":
			#MAJ nouvelle position du joueur
			self.target.old_position = body.get_collision_position()
			#définition de la direction pour l'animation
			self.direction_name = Tools.get_direction((self.target.old_position - get_collision_position()).normalized())
			#lancement du timer pour l'attaque
			$ShootLoopTimer.start()
			break

func decrease_life(var value):
	#animation touché
	.decrease_life(value)
	$ShootLoopTimer.start()
	emit_signal("hud_life_change_sig", (float(life)/life_max) * 100)
	if self.life == 0:
		die()

func _on_AnimationPlayer_animation_finished(anim_name):
	if !$ShootLoopTimer.is_stopped():
		play_animation(self.direction_name, "prepare_attack", $AnimatedSprite)
	else:
		self.state = WALK

func enter_in_another_area(var shape):
	var dir = -(shape.get_node("..").position - self.position).normalized()
	var angle = rand_range(-PI/2, PI/2)
	set_move(dir.rotated(angle))