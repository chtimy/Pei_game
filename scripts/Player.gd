extends "res://scripts/movable.gd"

signal hud_life_player_change_sig
signal enter_in_another_area
signal player_died

export (int) var range_attack

var destination = Vector2()
var direction = Tools.VEC_SOUTH
var velocity = Vector2()

func _ready():
	self.velocity = Vector2(0,0)
	self.destination = self.position
	
	connect("hud_life_player_change_sig", get_node("../.."), "change_HUD_life")

func _process(delta):
	move_and_slide(velocity)
	
	#which direction is the player
	if(velocity != Vector2(0,0)):
		self.direction = Tools.get_direction(velocity.normalized())
		play_animation(self.direction, "walk")
		
func stop():
	velocity = Vector2(0,0)
	play_animation(self.direction, "wait")
	
func set_move(var move, var factor_speed):
	factor_speed = clamp(factor_speed, 0.0, 1.0)
	velocity = move * SPEED * factor_speed
	
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
	play_animation(direction, "attack")
	for area in $View.get_overlapping_areas():
		var selectable = area.get_node("..")
		if selectable.is_in_group("Enemis") && area.get_name() == "Trigger":
			print("area : ", selectable, "group : ", selectable.get_groups())
			var pos_enemi = selectable.position + selectable.get_node("Collision").position + selectable.get_node("Collision").shape.extents/2.0
			var vec = (pos_enemi - self.position).normalized()
			var dir_player = Tools.get_direction_value(self.direction)
			var angle = vec.angle_to(dir_player)
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
