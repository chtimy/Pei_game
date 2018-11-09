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

func choose_level(var level_button, var stage_id, var level_id):
	if($image/Player/Position2D.global_position.distance_to(level_button.rect_position + level_button.rect_size*level_button.rect_scale/2.0) < 1):
		emit_signal("choose_level_signal", stage_id, level_id)
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
	print(player_position_from)
	print(player_position_to)
	move_animation.track_set_key_value(1,0, "walk_front")
	move_animation.track_set_key_value(2,0, cat_position_from)
	move_animation.track_set_key_value(2,1, cat_position_to)
	move_animation.track_set_key_value(3,0, "walk_front")
	move_animation.track_set_key_value(3,1, "wait_front")
	$AnimationPlayer.queue("move")
	
func unlock_level(var stage_id, var level_id):
	unlock_level_animation(stage_id, level_id)
	move_player(stage_id, level_id)
	
func unlock_level_animation(var stage_id, var level_id):
	self.stage_id_animation = stage_id
	self.level_id_animation = level_id
	var name = "Stage_" + String(stage_id)
	var stage = Tools.find_child_by_name(get_children(), name)
	var level = stage.get_child(level_id-1)
	var unlock_animation = $AnimationPlayer.get_animation("unlock_level")
	unlock_animation.track_set_key_value(0,0, get_level_center_position(level))
	$AnimationPlayer.queue("unlock_level")
	
func unlock_level_graphics():
	var name = "Stage_" + String(stage_id_animation)
	var stage = Tools.find_child_by_name(get_children(), name)
	var level = stage.get_child(level_id_animation-1)
	level.set_disabled(false)
	
func get_level_center_position(var level_node):
	return level_node.rect_position + (level_node.rect_size*level_node.rect_scale)/2.0
	
func get_level_node(var stage_id, var level_id):
	var name = "Stage_" + String(stage_id)
	var stage = Tools.find_child_by_name(get_children(), name)
	var level = stage.get_child(level_id-1)

func _on_AnimationPlayer_animation_finished(anim_name):
	if !self.queue_animation_functions.empty():
		self.queue_animation_functions.front().function.call_func(self.queue_animation_functions.front().args)
		self.queue_animation_functions.pop_front()
	
