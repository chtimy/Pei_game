extends Navigation2D

var cell_size = Vector2(64,64)
var map = [load("res://scenes/maps/Pattern01.tscn"), load("res://scenes/maps/Pattern02.tscn")]
var matrix = []
var current_map_id

func generate(var w, var h):
	matrix.resize(w)
	for i in range(w):
		matrix[i] = []
		matrix[i].resize(h)
	for i in range(w):
		for j in range(h):
			var n = randi() % map.size()
			matrix[i][j] = map[n].instance()
			add_child(matrix[i][j])
			matrix[i][j].pause()

func _ready():
	generate(2, 2)
	self.current_map_id = Vector2(0,0)
	matrix[0][0].play()

func change_map(var T):
	self.matrix[self.current_map_id.x][self.current_map_id.y].pause()
	self.current_map_id += T
	self.matrix[self.current_map_id.x][self.current_map_id.y].play()

func on_exit_area(var area, var direction):
	if direction == "right":
		if area.is_in_group("Player"):
			print("right")
			change_map(Vector2(1,0))
	elif direction == "left":
		if area.is_in_group("Player"):
			print("left")
			change_map(Vector2(1,0))
	elif direction == "south":
		if area.is_in_group("Player"):
			print("south")
			change_map(Vector2(1,0))
	elif direction == "north":
		if area.is_in_group("Player"):
			print("north")
			change_map(Vector2(1,0))