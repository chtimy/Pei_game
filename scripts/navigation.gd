extends Navigation2D

signal change_player_position

var cell_size = Vector2(64,64)
var maps_center = [load("res://scenes/maps/center/Pattern01.tscn"), load("res://scenes/maps/center/Pattern02.tscn")]
var maps_right = [load("res://scenes/maps/right_borders/Pattern01.tscn")]
var maps_left = [load("res://scenes/maps/left_borders/Pattern01.tscn")]
var maps_north = [load("res://scenes/maps/north_borders/Pattern01.tscn")]
var maps_south = [load("res://scenes/maps/south_borders/Pattern01.tscn")]
var maps_south_right = [load("res://scenes/maps/south_right_borders/Pattern01.tscn")]
var maps_south_left = [load("res://scenes/maps/south_left_borders/Pattern01.tscn")]
var maps_north_right = [load("res://scenes/maps/north_right_borders/Pattern01.tscn")]
var maps_north_left = [load("res://scenes/maps/north_left_borders/Pattern01.tscn")]
var maps_north_left_exit = [load("res://scenes/maps/north_left_borders/exit/Pattern01.tscn")]
var matrix = []
var current_map_id

func generate(var w, var h):
	matrix.resize(w)
	for i in range(w):
		matrix[i] = []
		matrix[i].resize(h)
	for i in range(w):
		for j in range(h):
			if i == 0 && j == 0 :
				var n = randi() % maps_north_left_exit.size()
				matrix[i][j] = maps_north_left_exit[n].instance()
			elif i == w-1 && j == h-1:
				var n = randi() % maps_south_right.size()
				matrix[i][j] = maps_south_right[n].instance()
			elif i == 0 && j == h-1:
				var n = randi() % maps_south_left.size()
				matrix[i][j] = maps_south_left[n].instance()
			elif i == w-1 && j == 0:
				var n = randi() % maps_north_right.size()
				matrix[i][j] = maps_north_right[n].instance()
			elif i == 0:
				var n = randi() % maps_left.size()
				matrix[i][j] = maps_left[n].instance()
			elif j == 0:
				var n = randi() % maps_north.size()
				matrix[i][j] = maps_north[n].instance()
			elif i == w-1:
				var n = randi() % maps_right.size()
				matrix[i][j] = maps_right[n].instance()
			elif j == h-1:
				var n = randi() % maps_south.size()
				matrix[i][j] = maps_south[n].instance()
			else:
				var n = randi() % maps_center.size()
				matrix[i][j] = maps_center[n].instance()

func _ready():
	generate(3,3)
	self.current_map_id = Vector2(0,0)
	add_child(matrix[0][0])

func change_map(var T):
	remove_child(self.matrix[self.current_map_id.x][self.current_map_id.y])
	self.current_map_id += T
	print(self.current_map_id)
	add_child(self.matrix[self.current_map_id.x][self.current_map_id.y])
	print("T : " ,T)
	print(self.matrix[self.current_map_id.x][self.current_map_id.y].exit[T])
	print(self.matrix[self.current_map_id.x][self.current_map_id.y])
	emit_signal("change_player_position", cell_size * self.matrix[self.current_map_id.x][self.current_map_id.y].exit[T])

func on_exit_area(var area, var direction):
	print(area.get_groups(), " " , direction)
	if direction == "right":
		if area.is_in_group("Player"):
			print("right")
			change_map(Vector2(1,0))
	elif direction == "left":
		if area.is_in_group("Player"):
			print("left")
			change_map(Vector2(-1,0))
	elif direction == "south":
		if area.is_in_group("Player"):
			print("south")
			change_map(Vector2(0,1))
	elif direction == "north":
		if area.is_in_group("Player"):
			print("north")
			change_map(Vector2(0,-1))