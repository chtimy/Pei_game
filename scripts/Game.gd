extends Node2D

export (PackedScene) var stagePackedScene
export (PackedScene) var gamePackedScene

var stages_scene
var game_scene

func _ready():
	States.read_dictionnary()
	self.stages_scene = stagePackedScene.instance()
	self.game_scene = gamePackedScene.instance()
	self.stages_scene.connect("enter_stage", self, "load_stage")

#lauch the game
func play_game():
	if !load_game():
		States.stage = 1
		States.level = 1
		save_game()
	remove_child($Menu)
	add_child(self.stages_scene)

func load_stage(var stage_id, var level_id):
	print(stage_id)
	add_child(self.game_scene)
	remove_child($stage)
	self.game_scene.start_level(stage_id, level_id)
	
func save_game():
	var file = File.new()
	file.open("slot.save", File.WRITE)
	if !file.is_open():
		print("Error, impossible to save the game")
		get_tree().quit()
		return false
	file.store_32(States.stage)
	file.store_32(States.level)
	file.close()
	
func load_game():
	var file = File.new()
	file.open("slot.save", File.WRITE)
	if !file.is_open():
		print("Error, impossible to load the game")
		return false
	States.stage = file.get_32()
	States.level = file.get_32()
	file.close()