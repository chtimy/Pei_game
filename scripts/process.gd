extends Node2D

enum {RIGHT = 2, LEFT = 0, UP = 1, DOWN = 3}

signal change_player_position
signal find_treasure_signal
signal finish_room_signal

var cell_size = Vector2(64,64)
var maps = [load("res://scenes/maps/Pattern01.tscn")]#, load("res://scenes/maps/Pattern02.tscn")]
var matrix = []
var current_map_id

func _ready():
	connect("change_player_position", get_node(".."), "change_player_position")
	connect("find_treasure_signal", get_node(".."), "find_treasure")
	connect("finish_room_signal", get_node(".."), "finish_room")
	
func freeze():
	for child in get_children():
		child.freeze()
		
func unfreeze():
	for child in get_children():
		child.unfreeze()
	
func find_treasure(var treasure):
	emit_signal("find_treasure_signal", treasure)
	emit_signal("finish_room_signal", self.current_map_id)

func generate(var w, var h, var word):
	matrix.resize(w)
	for i in range(w):
		matrix[i] = []
		matrix[i].resize(h)
	for i in range(w):
		for j in range(h):
			var n = randi() % maps.size()
			matrix[i][j] = maps[n].instance()
			matrix[i][j].layers = [matrix[i][j].get_node("layer_01"), matrix[i][j].get_node("layer_02"), matrix[i][j].get_node("layer_03"), matrix[i][j].get_node("layer_04")]
			if i == 0 && j == 0 :#north-west
				matrix[i][j].open_exit(DOWN)
				matrix[i][j].open_exit(RIGHT)
				matrix[i][j].put_door()
				matrix[i][j].put_terminal()
			elif i == w-1 && j == h-1:#south-east
				matrix[i][j].open_exit(UP)
				matrix[i][j].open_exit(LEFT)
			elif i == 0 && j == h-1:#south-west
				matrix[i][j].open_exit(UP)
				matrix[i][j].open_exit(RIGHT)
			elif i == w-1 && j == 0:#north-east
				matrix[i][j].open_exit(DOWN)
				matrix[i][j].open_exit(LEFT)
			elif i == 0:#west
				matrix[i][j].open_exit(RIGHT)
				matrix[i][j].open_exit(UP)
				matrix[i][j].open_exit(DOWN)
			elif j == 0:#north
				matrix[i][j].open_exit(DOWN)
				matrix[i][j].open_exit(RIGHT)
				matrix[i][j].open_exit(LEFT)
			elif i == w-1:#east
				matrix[i][j].open_exit(LEFT)
				matrix[i][j].open_exit(UP)
				matrix[i][j].open_exit(DOWN)
			elif j == h-1:#south
				matrix[i][j].open_exit(UP)
				matrix[i][j].open_exit(RIGHT)
				matrix[i][j].open_exit(LEFT)
			else:
				matrix[i][j].open_exit(LEFT)
				matrix[i][j].open_exit(RIGHT)
				matrix[i][j].open_exit(UP)
				matrix[i][j].open_exit(DOWN)
			matrix[i][j].init()
	self.current_map_id = Vector2(0,0)
	
	var alea = []
	for i in range(w):
		for j in range(h):
			alea.push_back(Vector2(i, j))
	alea = Tools.randomize_array(alea)
	# distribute the letters
	for i in range(word.length()):
		matrix[alea[i].x][alea[i].y].init_chest(Constants.LETTER, [word[i], i])
	for i in range(word.length(), alea.size()):
		matrix[alea[i].x][alea[i].y].init_chest(Constants.LIFE, [25])
		
	print(range(word.length()))
	print(range(word.length(), alea.size()))
	
	add_child(matrix[0][0])
	return Vector2(0,0)

func on_change_map(var T):
	call_deferred("change_map", T)

func change_map(var T):
	remove_child(self.matrix[self.current_map_id.x][self.current_map_id.y])
	self.current_map_id += T
	add_child(self.matrix[self.current_map_id.x][self.current_map_id.y])
	emit_signal("change_player_position", cell_size * self.matrix[self.current_map_id.x][self.current_map_id.y].exit[T], self.current_map_id)

func clear_map():
	var map = $Map
	call_deferred("remove_child", map)
	map.call_deferred("queue_free")
