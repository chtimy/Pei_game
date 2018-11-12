extends Node2D

signal end_level
signal save_game_signal
signal show_stages_signal
signal player_get_objet_signal
signal change_room_signal

var begin = Vector2()
var end = Vector2()
var path = []

var current_level
var current_stage

func _ready():
	randomize()
	connect("save_game_signal", get_node(".."), "save_game")
	connect("show_stages_signal", get_node(".."), "show_stages")
	connect("change_room_signal", $Menu/Minimap, "change_room")

################INIT###############
func init_word(var stage, var level):
	var index = randi()%States.words[States.stage-1][level-1].size()
	var word = States.words[States.stage-1][level-1][index]
	$Password/Terminal.set_password(word)
	return word.translation
	
################TERMINAL#################
func exit_terminal():
	$Password.hide()
	$HUD.show()
	$Level.unfreeze()

func show_terminal():
	$HUD.hide()
	$Password.show()
	$Level.freeze()

################GAME#################
func start_level(var stage, var level):
	self.current_level = level
	self.current_stage = stage
	#generate the level map
	var word = init_word(stage, level)
	#generate the word for the level
	var init_map_id = $Level.generate(word.length()/2, word.length()/2 + 1, word)
	$Level/Cat.update_position()
	#init minimap
	$Menu/Minimap.init($Level.matrix, init_map_id)
	#init the HUD
	$HUD.set_process(true)
	$HUD.show()
	
	$Level/Player.set_position($Level/Map/Player_initial_position.position)
	
func next_level():
	States.level += 1
	if (self.current_stage == States.stage && self.current_level >= States.level-1) || self.current_stage > States.stage:
		emit_signal("show_stages_signal", self.current_stage, self.current_level+1)
	else:
		emit_signal("show_stages_signal")
	
func stop_level(var win):
	var found_word = $Password/Terminal.word
	$Password/Terminal.clear()
	$Level.clear_map()
	$HUD.hide()
	if win:
		$Score/Score.win(found_word)

		var index = States.words[States.stage-1].find(found_word)
		if index != -1:
			States.words[States.stage-1].remove(index)
			States.used_words[States.stage-1].push_back(found_word)
		emit_signal("save_game_signal")
	else:
		$Score/Score.loose()
	$Score.show()

func valid_password():
	exit_terminal()
	unfreeze()
	$Level/Map.unlock_door()

func change_player_position(var position, var current_map_id):
	$Level/Player.position = position;
	$Level/Cat.update_position()
	$Level/Player.stop()
	emit_signal("change_room_signal", current_map_id)

func find_treasure(var treasure):
	if treasure.type == Constants.LETTER:
		emit_signal("player_get_objet_signal", "letter")
		$Password/Terminal.active_letter({"letter" : treasure.args[0], "position" : treasure.args[1]})
	elif treasure.type == Constants.LIFE:
		emit_signal("player_get_objet_signal", "heart")
		$Level/Player.increase_life(treasure.args[0])

func finish_room(var current_room_id):
	$Menu/Minimap.finish_room(current_room_id)
	
func _on_character_dead(var body):
	if body.is_in_group("Players"):
		stop_level(false)
			
func show_minimap():
	$Menu.show()
	$HUD.hide()
	
func hide_minimap():
	$Menu.hide()
	$HUD.show()
