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
	$Level.generate(word.length()/2, word.length()/2 + 1, word)
	#init the HUD
	$HUD.set_process(true)
	$HUD/Control.show()
	
	$Level/Player.set_position($Level/Map/Player_initial_position.position)
	
func stop_level(var win):
	var found_word = $Password/Terminal.word
	
	$Password/Terminal.clear()
	$Level.clear_map()
	
	$Score/Score.init(found_word)
	$Score/Score.show()
	
	var index = States.words[States.stage-1].find(found_word)
	if index != -1:
		States.words[States.stage-1].remove(index)
		States.used_words[States.stage-1].push_back(found_word)
	States.level += 1

################SIGNALS##################
func valid_password():
	$Password/Terminal.hide()
	unfreeze()
	$Level/Map.unlock_door()

func change_player_position(var position):
	$Level/Player.position = position;
	$Level/Cat.update_position()
	$Level/Player.stop()

func _on_HUD_attack_button():
	$Level/Player.attack_on()

func find_letter(var letter, var letter_position):
	$Password/Terminal.active_letter({"letter" : letter, "position" : letter_position})
	
func change_HUD_life(var value):
	get_node("HUD/Control/LifeBar").value = value