extends Node2D

var areas = []
var finish = false
var enemis = []
var letter = null
var letter_position = null

var ENEMI_SCENE = load("res://scenes/enemi.tscn")

func init(var letter, var letter_position):
	var nb_enemis = randi() % 3
	for i in range(nb_enemis):
		var enemi = ENEMI_SCENE.instance()
		enemi.add_to_group("Enemis")
		enemi.add_to_group("Movables")
		add_child(enemi)
		enemi.set_position(Vector2(200 + i * 100, 300))
		self.enemis.push_back(enemi)
	init_clue(letter, letter_position)
		
func init_clue(var letter, var letter_position):
	self.letter = letter
	self.letter_position = letter_position
	
func enemi_killed(var enemi):
	self.enemis.remove(enemi)
	if enemis.size() == 0:
		finish_room()
		
func finish_room():
	pass

func pause():
	pass
	
func play():
	