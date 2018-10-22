extends "res://scripts/movable.gd"

signal hud_life_player_change_sig
signal enter_in_another_area
signal player_died

export (int) var range_attack

var destination = Vector2()
var direction_vec = Vector2(0.0, 0.0)
var direction_name = Tools.VEC_SOUTH
var velocity = Vector2()
var factor_speed = 0.0

func _ready():
	self.velocity = Vector2(0,0)
	connect("hud_life_player_change_sig", get_node("../.."), "change_HUD_life")
	get_node("AnimatedSprite").connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")

func _process(delta):
	move_and_slide(velocity)
	
	#which direction is the player
	if(self.velocity != Vector2(0,0)):
		self.direction_name = Tools.get_direction(self.velocity.normalized())
		play_animation(self.direction_name, "walk", $AnimatedSprite)
		self.direction_vec = self.velocity.normalized()
		
func stop():
	velocity = Vector2(0,0)
	play_animation(self.direction_name, "wait", $AnimatedSprite)
	
func set_move(var move, var factor_speed):
	self.factor_speed = clamp(factor_speed, 0.0, 1.0)
	velocity = move * SPEED * self.factor_speed
	
func die():
	print("dead")
	emit_signal("player_died")
	
#func _on_View_area_entered(area):
#	var selectable = area.get_node("..")
#	print(selectable)
#	if selectable.is_in_group("Enemis") :
#		print("area : ", selectable, "group : ", selectable.get_groups())
#		self.enemis_viewed.push_back(selectable)
#
#func _on_View_area_exited(area):
#	var selectable = area.get_node("..")
#	if selectable.is_in_group("Enemis"):
#		var index = self.enemis_viewed.find(selectable)
#		if index != -1:
#			self.enemis_viewed.remove(index)
	
func take_damages(var value):
	#play_animation(self.direction, "touched")
	decrease_life(value)
	emit_signal("hud_life_player_change_sig", life)
			
func attack_on():
	$attack_effects.rotation = Vector2(0,1).angle_to(self.direction_vec)
	print($attack_effects.rotation)
	print(self.direction_vec)
	play_animation(self.direction_name, "attack", $AnimatedSprite)
	$attack_effects.play("normal")
	for area in $View.get_overlapping_areas():
		var selectable = area.get_node("..")
		if selectable.is_in_group("Enemis") && area.get_name() == "Trigger":
			print("area : ", selectable, "group : ", selectable.get_groups())
			var pos_enemi = selectable.position + selectable.get_node("Collision").position + selectable.get_node("Collision").shape.extents/2.0
			var vec = (pos_enemi - self.position).normalized()
#			var dir_player = Tools.get_direction_value(self.direction_name)
			var angle = vec.angle_to(self.direction_vec)
			if angle <= PI/4.0 || angle >= -PI/4.0:
				selectable.take_damages(self.hit)
	

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
