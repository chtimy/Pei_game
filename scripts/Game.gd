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
		
func show_stages(var stage_id= -1, var level_id = -1):
	if self.game_scene.is_inside_tree():
		remove_child(self.game_scene)
	self.menu_scene.hide()
	self.stages_scene.show()
	if stage_id != -1 && level_id != -1:
		self.stages_scene.unlock_level(stage_id, level_id)
	
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
	file.close()
	
func load_game():
	var file = File.new()
	file.open("slot.save", File.READ)
	if !file.is_open() || file.eof_reached():
		file.close()
		return false
		
	States.stage = file.get_32()
	States.level = file.get_32()
	if States.stage == 0 || States.level == 0:
		file.close()
		return false
	file.close()
	return true