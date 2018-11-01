extends Node2D

signal end_level

var begin = Vector2()
var end = Vector2()
var path = []

func _ready():
	randomize()
	$Password/Terminal.connect("close_terminal", self, "exit_terminal")
	$Password/Terminal.connect("valid_password", self, "valid_password")
	$Score/Score.connect("next_level", self, "start_level")

################INIT###############
func init_word():
	var index = randi()%States.words[States.stage-1].size()
	var word = States.words[States.stage-1][index]
	$Password/Terminal.set_password(word)
	return word.translation
	
################TERMINAL#################
func exit_terminal():
	$Password.hide()
	$HUD.show()
	unfreeze()

func show_terminal():
	$HUD.hide()
	$Password.show()
	freeze()

################GAME#################
func freeze():
	set_process_input(false)
#	$Level.freeze()

func unfreeze():
	set_process_input(true)
	$Level/Player.unfreeze()

func start_level():
	#generate the level map
	var word = init_word()
	#generate the word for the level
	var init_map_id = $Level.generate(word.length()/2, word.length()/2 + 1, word)
	$Level/Cat.update_position()
	#init minimap
	$Menu/Minimap.init($Level.matrix, init_map_id)
	#init the HUD
	$HUD.set_process(true)
	$HUD.show()
	
	$Level/Player.set_position($Level/Map/Player_initial_position.position)
	
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
		States.level += 1
	else:
		$Score/Score.loose()
	$Score.show()

################SIGNALS##################
func valid_password():
	exit_terminal()
	unfreeze()
	$Level/Map.unlock_door()

func change_player_position(var position):
	$Level/Player.position = position;
	$Level/Cat.update_position()
	$Level/Player.stop()

func _on_HUD_attack_button():
	$Level/Player.attack_on()

func find_treasure(var treasure):
	if treasure.type == "letter":
		$Password/Terminal.active_letter(treasure)
	
func change_HUD_life(var value):
	get_node("Level/Cat").change_life(value)
	
func _on_Player_died():
	stop_level(false)
	
func show_minimap():
	$Menu.show()
	$HUD.hide()
	
func hide_minimap():
	$Menu.hide()
	$HUD.show()