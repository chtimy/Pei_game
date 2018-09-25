extends Node2D

export (PackedScene) var gamePackedScene

#lauch the game
func _on_Play_button_up():
	remove_child($Menu)
	var game = gamePackedScene.instance()
	game.start_level()
	add_child(game)