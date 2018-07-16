extends Node2D

export (PackedScene) var gamePackedScene

#lauch the game
func _on_Play_button_up():
	remove_child($Menu)
	var game = gamePackedScene.instance()
	game.start_game()
	add_child(game)
#
#func clear_enemis():
#	var nb_enemis = self.enemis.size()
#	for i in range(nb_enemis):
#		delete_object(self.enemis[nb_enemis - i - 1])
#	for node in get_children():
#		if node.is_in_group("Bullets"):
#			call_deferred("remove_child", node)
#			node.call_deferred("queue_free")