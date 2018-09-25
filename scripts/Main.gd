extends Node2D

var begin = Vector2()
var end = Vector2()
var path = []

func _ready():
	pass

################INIT###############
func init_word():
	var word = {"name": "house", "translation" : "maison"}
	$Password/Terminal.set_password(word)
	return word.translation
	
################TERMINAL#################
func exit_terminal():
	$Password/Terminal.hide()
	unfreeze()

func show_terminal():
	$Password/Terminal.show()
	freeze()

################GAME#################		
func freeze():
	set_process_input(false)
#	$Game.freeze()

func unfreeze():
	set_process_input(true)
	$Game/Player.unfreeze()

func start_level():
	#generate the level map
	var word = init_word()
	#generate the word for the level
	$Game.generate(word.length()/2, word.length()/2 + 1, word)
#	$Game/Map.init_enemis(word.length(), word)	
	#init the HUD
	$HUD.init()
	$HUD/Control.show()
	
func stop_level(var win):
#	if win:
#
#	else win:
		
	call_deferred("remove_child", $HUD)
	$Game.call_deferred("remove_child", $Game/Player)
	for child in $Game/Map.get_children():
		$Game/Map.call_deferred("remove_child", child)

################SIGNALS##################
func _on_Control_valid_password():
	$Password/Terminal.hide()
	unfreeze()
	$Game/Map.unlock_door()

func change_player_position(var position):
	$Game/Player.position = position;
	$Game/Player.stop()

func _on_HUD_attack_button():
	$Game/Player.attack()

func find_letter(var letter, var letter_position):
	$Password/Terminal.active_letter({"letter" : letter, "position" : letter_position})