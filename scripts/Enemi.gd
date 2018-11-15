extends "res://scripts/movable.gd"

signal touched_from_enemi
signal enemi_died_sig
signal mvt_animation_finished

export (float) var width_attack

enum STATE{WALK, ANIMATION, NOTHING}

var target = {"target": null, "position" : Vector2(0,0), "is_visible" : false}
var state = WALK

func _ready():
	randomize()	
	self.life = self.life_max
	self.direction_name = Tools.VEC_LEFT
	
	self.connect("touched_from_enemi", get_tree().root.get_node("Game"), "on_touched_enemi")
	self.connect("hud_life_change_sig", $TextureProgress, "set_value")
	self.connect("character_dead_signal", get_node(".."), "character_dead")
	
	$ShootLoopTimer.set_wait_time(RECOVERY_ATTACK_TIME)
	$ShootLoopTimer.set_one_shot(true)
	
func _process(delta):
	if state == WALK:
		$AnimationPivot.set_rotation(0)
		move_and_slide(velocity)
		if(self.velocity != Vector2(0,0)):
			self.direction_name = Tools.get_direction(self.velocity.normalized())
			play_animation(self.direction_name, "walk", $AnimationPivot/AnimatedSprite)
	elif state == ANIMATION:
		move_and_slide(self.velocity_push)
		self.remained_velocity -= 1
		self.velocity_push *= self.damp_push
		if self.remained_velocity == 0:
			self.velocity_push = Vector2(0,0)

func set_move(var move, var factor_speed):
	self.velocity = move.normalized() * SPEED * factor_speed

func _on_View_body_entered(body):
	if $ShootLoopTimer.is_stopped() && body.is_in_group("Players"):
		prepare_to_attack(body)
		
func prepare_to_attack(var body):
	self.target.body = body
	self.target.old_position = body.get_collision_position()
	#lancement du timer pour l'attaque
	$ShootLoopTimer.start()
	#définition de la direction pour l'animation
	var direction_attack = (self.target.old_position - get_collision_position()).normalized()
	self.direction_name = Tools.get_direction(direction_attack)
	#on joue l'animation pour la préparation de l'attaque
	$AnimationPivot/AnimatedSprite.set_animation("prepare_attack")
	$AnimationPivot.set_rotation(Vector2(0,1).angle_to(direction_attack))
	
	var current_position = get_collision_position()
	var perpendiculaire_vector = Vector2(direction_attack.y, -direction_attack.x)
	var largeur = self.width_attack
	var longueur = self.range_attack
		
	var b = get_collision_center() + (perpendiculaire_vector * largeur) / 2.0
	var a = get_collision_center() - (perpendiculaire_vector * largeur) / 2.0
	var c = b + direction_attack * longueur
	var d = a + direction_attack * longueur
	$attack/CollisionPolygon2D.polygon = [b, a, d, c]
	
	#on désactive le process afin que l'ennemi s'arête
	self.state = ANIMATION

func attack_on():
	#play_animation(self.direction_name, "attack", $AnimatedSprite)
	#calcul si le joueur est toujours dans la zone d'attaque de l'ennemi
	var current_position = get_collision_position()
	var enemi_current_position = self.target.body.get_collision_position()
	var vector_attack = (self.target.old_position - current_position).normalized()
	
	#on joue l"animation d'attaque
	move_animation(self.position, self.position + vector_attack * self.move_attack, "attack", Tools.rad_in_deg(Tools.get_direction_value(self.direction_name).angle_to(vector_attack)))
	
	#check si çà touche
	for body in $attack.get_overlapping_bodies():
		if body.is_in_group("Players"):
			self.target.body.decrease_life(self.hit)
			self.target.body.move_animation(self.target.body.position, self.target.body.position + vector_attack * self.move_attack, get_animation(self.target.body.direction_name, "wait"))
	
func move_animation(var init_position, new_position, var animation_name, var rotation_in_degrees):
	process_move_velocity((new_position - init_position).normalized(), 1000, $AnimationPlayer.get_animation("movement").length, 0.8)
	$AnimationPlayer.get_animation("movement").track_set_key_value(0,0, animation_name)
	$AnimationPlayer.get_animation("movement").track_set_key_value(1,0, rotation_in_degrees)
	$AnimationPlayer.play("movement")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name =="movement":
		var bodies = $View.get_overlapping_bodies()
		var found = false
		for body in bodies:
			if body.is_in_group("Players"):
				prepare_to_attack(body)
				found = true
				break
		if !found:
			self.state = WALK
		
func _on_ShootLoopTimer_timeout():
	#quand le timer s'arrête, l'ennemi attaque
	attack_on()

func enter_in_another_area(var shape):
	var dir = -(shape.get_node("..").position - self.position).normalized()
	var angle = rand_range(-PI/2, PI/2)
	set_move(dir.rotated(angle))
	
func _on_changement_direction_timeout():
	set_move(Vector2(rand_range(-1, 1), rand_range(-1, 1)), 1)
	
func decrease_life(var value):
	#animation touché
	.decrease_life(value)
	emit_signal("hud_life_change_sig", (float(life)/life_max) * 100)
	if self.life == 0:
		die()
