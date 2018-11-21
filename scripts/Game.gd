extends Node2D

export (PackedScene) var stagePackedScene
export (PackedScene) var gamePackedScene

var stages_scene
var game_scene
var menu_scene

func _ready():
	States.read_dictionnary()
	self.stages_scene = stagePackedScene.instance()
	self.game_scene = gamePackedScene.instance()
	self.menu_scene = $Menu
	self.stages_scene.connect("choose_level_signal", self, "load_level")
	init_game()
	add_child(stages_scene)
	self.stages_scene.hide()

#lauch the game
func init_game():
	if !load_game():
		States.stage = 1
		States.level = 1
		save_game()
		
func show_stages(var stage_id = -1, var level_id = -1):
	if self.game_scene.is_inside_tree():
		remove_child(self.game_scene)
	self.menu_scene.hide()
	self.stages_scene.show()
	if stage_id != -1 && level_id != -1:
		self.stages_scene.complete_level(stage_id, level_id)
	
func options_game():
	pass

func exit_game():
	get_tree().quit()

func load_level(var stage_id, var level_id):
	self.menu_scene.hide()
	self.stages_scene.hide()
	if !self.game_scene.is_inside_tree():
		add_child(self.game_scene)
	self.game_scene.start_level(stage_id, level_id)
	
func save_game():
	var file = File.new()
	file.open("slot.save", File.WRITE)
	if !file.is_open():
		print("Error, impossible to save the game")
		file.close()
		get_tree().quit()
	file.store_32(States.stage)
	file.store_32(States.level)
	file.store_32(States.used_words.size())
	for stage_id in range(States.used_words.size()):
		file.store_32(States.used_words[stage_id].size())
		for level_id in range(States.used_words[stage_id].size()):
			file.store_32(States.used_words[stage_id][level_id].size())
			print(States.used_words)
			for word_id in range(States.used_words[stage_id][level_id].size()):
				file.store_string(States.used_words[stage_id][level_id][word_id].name)
				file.store_string(":")
				file.store_string(States.used_words[stage_id][level_id][word_id].translation)
				file.store_string(":")
				
	file.close()
	
func load_game():
	var file = File.new()
	file.open("slot.save", File.READ)
	if !file.is_open() || file.eof_reached():
		file.close()
		return false
		
	States.stage = file.get_32()
	States.level = file.get_32()
	var size_used_words_stages = file.get_32()
	for stage_id in range(size_used_words_stages):
		var size_used_words_levels = file.get_32()
		for level_id in range(size_used_words_levels):
			var nb_words = file.get_32() * 2
			var line = file.get_line().split(":")
			print("line : ", line)
			for word_id in range(0, nb_words, 2):
				var word = {"name" : line[word_id], "translation" : line[word_id+1]}
				States.finish_word(word, stage_id+1, level_id+1)
	file.close()
	if States.stage == 0 || States.level == 0:
		return false
	return true