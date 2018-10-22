extends Node2D

signal show_terminal_sig
signal stop_level_sig
signal change_map_sig
signal find_letter_sig

var layers

enum {NORMAL_MODE = 0, PASSWORD_ZONA = 1}
var mode = NORMAL_MODE

var exit_positions
var door_position
var terminal_position
var exit
var size

enum {RIGHT = 2, LEFT = 0, UP = 1, DOWN = 3}

var areas = []
var finish = false
var enemis = []
var letter = null
var letter_position = null
var door = null

var ENEMI_SCENE = load("res://scenes/enemi.tscn")


func _ready():
	#top signals
	connect("stop_level_sig", get_node("../.."), "stop_level")
	connect("show_terminal_sig", get_node("../.."), "show_terminal")
	connect("change_map_sig", get_node(".."), "on_change_map")
	connect("find_letter_sig", get_node("../.."), "find_letter")
	#down signals
	for child in get_children():
		if child.get_name() == "left_exit":
			child.connect("area_entered", self, "enter_area", ["left"])
		elif child.get_name() == "right_exit":
			child.connect("area_entered", self, "enter_area", ["right"])
		elif child.get_name() == "north_exit":
			child.connect("area_entered", self, "enter_area", ["north"])
		elif child.get_name() == "south_exit":
			child.connect("area_entered", self, "enter_area", ["south"])
		elif child.get_name() == "Terminal":
			child.connect("area_entered", self, "enter_area", ["terminal"])
			child.connect("area_exited", self, "on_exit_zone_terminal")
		elif child.get_name() == "Terminal_action":
			child.connect("input_event", self, "_on_Terminal_action_input_event")
		elif child.get_name() == "Door":
			child.connect("area_entered", self, "enter_area", ["door"])
	
func init_chest(var letter, var letter_position):
	init_clue(letter, letter_position)
	
func init():
	var nb_enemis = randi() % 3
	for i in range(nb_enemis):
		var enemi = ENEMI_SCENE.instance()
		enemi.add_to_group("Enemis")
		enemi.add_to_group("Movables")
		add_child(enemi)
		enemi.set_position($Position_spawners.get_children()[i].position)
		self.enemis.push_back(enemi)

func init_clue(var letter, var letter_position):
	self.letter = letter
	self.letter_position = letter_position

func enemi_killed(var enemi):
	var id = enemis.find(enemi)
	if id != -1:
		self.enemis.remove(id)
	enemi.call_deferred("queue_free")
	if enemis.size() == 0:
		finish_room()

func finish_room():
	print("finish room")
	show_chest()

func show_chest():
	var chest = find_node("Chest")
	if chest:
		chest.show()
		chest.get_node("Area2D").connect("area_entered", self, "touch_chest")

func touch_chest(var area):
	var chest = find_node("Chest")
	chest.hide()
	call_deferred("queue_free", chest)
	if(self.letter):
		emit_signal("find_letter_sig", self.letter, self.letter_position)
	#else:
		#emit_signal("find_treasure", self.treasure)

func pause():
	pass
	
func play():
	pass
	
func unlock_door():
	var layer = self.layers[0]
	layer.set_cellv(door_position.position + door_position.extend, -1)
	layer.set_cellv(door_position.position, self.layers[0].tile_set.find_tile_by_name("opened_main_door"))

func enter_area(var area, var direction):
	if direction == "right":
		if area.is_in_group("Player"):
			print("right")
			emit_signal("change_map_sig", Vector2(1,0))
	elif direction == "left":
		if area.is_in_group("Player"):
			print("left")
			emit_signal("change_map_sig", Vector2(-1,0))
	elif direction == "south":
		if area.is_in_group("Player"):
			print("south")
			emit_signal("change_map_sig", Vector2(0,1))
	elif direction == "north":
		if area.is_in_group("Player"):
			print("north")
			emit_signal("change_map_sig", Vector2(0,-1))
	elif direction == "door":
		if area.is_in_group("Player"):
			print("door")
			emit_signal("stop_level_sig", true)
	elif direction == "terminal":
		if area.is_in_group("Player"):
			print("terminal")
			self.mode = PASSWORD_ZONA

##########################SIGNALS############################""
func _on_Terminal_action_input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch && event.pressed:
		if self.mode == PASSWORD_ZONA:
			emit_signal("show_terminal_sig")

func on_exit_zone_terminal(var shape):
	if shape.get_node("..").name == "Player":
		self.mode = NORMAL_MODE

###########################"MODIFY MAP#############################
func open_exit(var direction):
	var exit_position = exit_positions[direction].position
	var layer = get_node(exit_positions[direction].layer)
	var cell_size = layer.cell_size
	layer.set_cellv(exit_position, -1)
	for dir_vec in exit_positions[direction].extend:
		layer.set_cellv(exit_position + dir_vec, -1)
	layer.set_cellv(exit_position, exit_positions[direction].door, exit_positions[direction].flip_x, exit_positions[direction].flip_y, exit_positions[direction].transpose)
	
	var area = Area2D.new()
	var name = get_exit_name(direction)
	area.set_name(name)
	var zona = CollisionShape2D.new()
	zona.shape = RectangleShape2D.new()
	if exit_positions[direction].layer == "layer_01":
		zona.shape.extents = get_exit_extents(direction, layer.cell_size)
		zona.set_position(exit_position * cell_size + zona.shape.extents)
	else:
		var size = get_exit_extents(direction, layer.cell_size)
		size.y = size.y/2.0
		zona.shape.extents = size
		var position = exit_position * cell_size + get_exit_extents(direction, layer.cell_size)
		position.y = position.y + zona.shape.extents.y
		zona.set_position(exit_position * cell_size + get_exit_extents(direction, layer.cell_size))
	area.add_child(zona)
	add_child(area)

func get_exit_name(var direction):
	if direction == UP:
		return "north_exit"
	elif direction == DOWN:
		return "south_exit"
	elif direction == RIGHT:
		return "right_exit"
	elif direction == LEFT:
		return "left_exit"
		
func get_exit_extents(var direction, var cell_size):
	if direction == UP:
		return Vector2(cell_size.x, cell_size.y / 2)
	elif direction == DOWN:
		return Vector2(cell_size.x, cell_size.y / 2)
	elif direction == RIGHT:
		return Vector2(cell_size.x / 2, cell_size.y)
	elif direction == LEFT:
		return Vector2(cell_size.x / 2, cell_size.y)
	
func put_door():
	var layer = self.layers[0]
	var cell_size = layer.cell_size
	layer.set_cellv(door_position.position, layer.tile_set.find_tile_by_name("main_door"))
	layer.set_cellv(door_position.position + door_position.extend, -1)
	var area = Area2D.new()
	area.set_name("Door")
	var zona = CollisionShape2D.new()
	zona.shape = RectangleShape2D.new()
	zona.shape.extents = Vector2(cell_size.x, cell_size.y /2)
	zona.set_position(door_position.position * cell_size + Vector2(cell_size.x, cell_size.y/2))
	area.add_child(zona)
	add_child(area)
	
func put_terminal():
	var layer = self.layers[3]
	var cell_size = layer.cell_size
	layer.set_cellv(terminal_position, layer.tile_set.find_tile_by_name("terminal"))
	#area clicked terminal
	var area = Area2D.new()
	area.set_name("Terminal_action")
	var zona = CollisionShape2D.new()
	zona.shape = RectangleShape2D.new()
	zona.shape.extents = cell_size / 2
	zona.set_position(terminal_position * cell_size + cell_size / 2)
	area.add_child(zona)
	add_child(area)
	#area enter terminal
	area = Area2D.new()
	area.set_name("Terminal")
	zona = CollisionShape2D.new()
	zona.shape = CircleShape2D.new()
	zona.shape.radius = cell_size.x
	zona.set_position(terminal_position * cell_size + Vector2(cell_size.x / 2, cell_size.y))
	area.add_child(zona)
	add_child(area)
