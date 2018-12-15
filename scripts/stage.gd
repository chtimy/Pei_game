extends Control

export (Vector2) var offset_vector

signal choose_level_signal

var stage_id_animation
var level_id_animation

var current_stage_id
var current_level_id

var queue_animation_functions = []

func _ready():
	var name = "Stage_" + String(States.stage)
	var stage = Tools.find_child_by_name(get_children(), name)
	var level = stage.get_child(States.level-1)
	$image/Player.position = get_level_center_position(level) - $image/Player/Position2D.position
	$image/Cat.position = get_level_center_position(level) - $image/Player/Position2D.position + offset_vector
	self.current_stage_id = States.stage
	self.current_level_id = States.level
	
	#add experience
	for stage_id in range(States.words.size()):
		for level_id in range(States.words[stage_id].size()):
			complete_level(stage_id+1, level_id+1, true)
			
#
#			var value = float(States.used_words[stage_id][level_id].size()) / (States.words[stage_id][level_id].size() + States.used_words[stage_id][level_id].size()) * 100
#			name = "Stage_" + String(stage_id)
#			stage = Tools.find_child_by_name(get_children(), name)
#			level = stage.get_child(level_id-1)
#			var fill_level_anim = level.get_node("AnimationPlayer").get_animation("fill")
#			fill_level_anim.track_set_key_value(0,0, level.get_node("TextureProgress").value)
#			fill_level_anim.track_set_key_value(0,1, value)
#			level.get_node("AnimationPlayer").play("fill")
#			#if level complete
#			if value >= 100:
#				level.get_node("AnimationPlayer").queue("finish")
#
#	#unlock levels
#	var total = States.get_nb_used_words()
#	for i in range(States.used_words.size()):
#		name = "Stage_" + String(i+1)
#		stage = Tools.find_child_by_name(get_children(), name)
#		children = stage.get_children()
#		for j in range(children.size()):
#			if States.unlock_level[i][j] <= total && children[j].is_disabled():
#				unlock_level(i+1, j+1)

func choose_level(var level_button, var stage_id, var level_id):
	if($image/Player/Position2D.global_position.distance_to(level_button.rect_position + level_button.rect_size*level_button.rect_scale/2.0) < 1):
		emit_signal("choose_level_signal", stage_id, level_id)
		States.level = level_id
		States.stage = stage_id
	else:
		var destination = level_id
		var from = self.current_level_id
		var step = clamp(destination - from, -1, 1)
		print(step, " ", from, " ", destination)
		var i = from
		while i != destination:
			move_player(stage_id, i + step)
			i += step
	
func move_player(var stage_id, var level_id):
	self.current_level_id = level_id
	self.current_stage_id = stage_id
	play_animation(funcref(self, "move_player_animation"), [stage_id, level_id])
	
func play_animation(var function, var args):
	if $AnimationPlayer.is_playing():
		self.queue_animation_functions.append({'function' : function, 'args' : args})
	else:
		function.call_func(args)
	
func move_player_animation(var args):
	var stage_id = args[0]
	var level_id = args[1]
	var name = "Stage_" + String(stage_id)
	var stage = Tools.find_child_by_name(get_children(), name)
	var level = stage.get_child(level_id-1)
	var player_position_from = $image/Player.position
	var player_position_to = get_level_center_position(level) - $image/Player/Position2D.position
	var cat_position_from = $image/Player.position
	var cat_position_to = get_level_center_position(level) - $image/Player/Position2D.position + offset_vector
	
	var move_animation = $AnimationPlayer.get_animation("move")
	move_animation.track_set_key_value(0,0, player_position_from)
	move_animation.track_set_key_value(0,1, player_position_to)
	move_animation.track_set_key_value(1,0, "walk_front")
	move_animation.track_set_key_value(2,0, cat_position_from)
	move_animation.track_set_key_value(2,1, cat_position_to)
	move_animation.track_set_key_value(3,0, "walk_front")
	move_animation.track_set_key_value(3,1, "wait_front")
	$AnimationPlayer.queue("move")
	
func unlock_level(var stage_id, var level_id, var off_animation = false):
	self.stage_id_animation = stage_id
	self.level_id_animation = level_id
	var name = "Stage_" + String(stage_id)
	var stage = Tools.find_child_by_name(get_children(), name)
	var level = stage.get_child(level_id-1)
	if off_animation:
		level.set_disabled(false)
	else:
		unlock_level_animation(level)
	
func unlock_level_animation(var level):
	var unlock_animation = $AnimationPlayer.get_animation("unlock_level")
	unlock_animation.track_set_key_value(0,0, get_level_center_position(level))
	$AnimationPlayer.queue("unlock_level")
	
func unlock_level_graphics():
	var name = "Stage_" + String(stage_id_animation)
	var stage = Tools.find_child_by_name(get_children(), name)
	var level = stage.get_child(level_id_animation-1)
	level.set_disabled(false)
	
func complete_level(var stage_id, var level_id, var off_animation = false):
	var value = float(States.used_words[stage_id-1][level_id-1].size()) / (States.words[stage_id-1][level_id-1].size() + States.used_words[stage_id-1][level_id-1].size()) * 100
	print(States.words[stage_id-1][level_id-1].size())
	print(States.used_words[stage_id-1][level_id-1].size())
	print ("value : " , value)
	var name = "Stage_" + String(stage_id)
	var stage = Tools.find_child_by_name(get_children(), name)
	var level = stage.get_child(level_id-1)
	if off_animation:
		level.get_node("TextureProgress").value = value
		if value >= 100:
			level.set_sprite(load("res://assets/stages/star.png"))
	else:
		complete_level_animation(level, value)
	check_levels(off_animation)

func complete_level_animation(var level, var value):
	var fill_level_anim = level.get_node("AnimationPlayer").get_animation("fill")
	fill_level_anim.track_set_key_value(0,0, level.get_node("TextureProgress").value)
	fill_level_anim.track_set_key_value(0,1, value)
	level.get_node("AnimationPlayer").play("fill")
	#if level complete
	if value >= 100:
		level.get_node("AnimationPlayer").queue("finish")
	
func check_levels(var off_animation = false):
	var total = States.get_nb_used_words()
	for i in range(States.used_words.size()):
		var name = "Stage_" + String(i+1)
		var stage = Tools.find_child_by_name(get_children(), name)
		var children = stage.get_children()
		for j in range(children.size()):
			if States.unlock_level[i][j] <= total && children[j].is_disabled():
				unlock_level(i+1, j+1, off_animation)
	
func get_level_center_position(var level_node):
	return level_node.rect_position + (level_node.rect_size*level_node.rect_scale)/2.0

func _on_AnimationPlayer_animation_finished(anim_name):
	if !self.queue_animation_functions.empty():
		self.queue_animation_functions.front().function.call_func(self.queue_animation_functions.front().args)
		self.queue_animation_functions.pop_front()
	
