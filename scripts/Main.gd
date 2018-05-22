extends Node2D

var begin = Vector2()
var end = Vector2()
var path = []

var enemis = []
var terminal_tile
var door_tile

enum {NORMAL_MODE = 0, PASSWORD_ZONA = 1}
var mode = NORMAL_MODE

func _ready():
#	var cells = $Navigation2D/TileMap.get_used_cells()
#	print(cells)
#	for cell in cells:
#		if cell.get_name() == "door":
#			door_tile = cell.get_
	self.door_tile = Vector2(9, 0)

	var word = init_word()
	init_enemis(word.length())
	
	$Camera2D.set_position($Player.position)
	
func init_word():
	var word = {"name": "house", "translation" : "maison"}
	$Password/Terminal.set_password(word)
	
	var tile_map = $Navigation2D/TileMap
	var area2D = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.set_radius(100)
	shape.set_shape(circle)
	area2D.add_child(shape)
	var position = Vector2(11, 0) * tile_map.cell_size + Vector2(tile_map.cell_size.x/2, 0)
	area2D.set_position(position)
	add_child(area2D)
	area2D.connect("area_entered", self, "enter_password_zona")
	area2D = Area2D.new()
	shape = CollisionShape2D.new()
	var square = RectangleShape2D.new()
	square.set_extents(Vector2(64, 64))
	shape.set_shape(square)
	area2D.add_child(shape)
	position = Vector2(11, 0) * 64 + Vector2(32, 0)
	area2D.set_position(position)
	add_child(area2D)
	area2D.connect("input_event", self, "enter_password")

	return word.translation
	
func init_enemis(var nb):
	var ENEMI_SCENE = load("res://scenes/enemi.tscn")
	for i in range(nb):
		var enemi = ENEMI_SCENE.instance()
		enemi.add_to_group("Enemis")
		enemi.add_to_group("Movables")
		var word = $Password/Terminal.word.translation
		enemi.set_clue({"letter" : word[i], "position" : i})
		add_child_below_node($Player, enemi)
		enemi.set_position(Vector2(200 + i * 100, 300))
		self.enemis.push_back(enemi)

func update_path():
	var p = $Navigation2D.get_simple_path(begin, end, true)
	path = Array(p) # PoolVector2Array too complex to use, convert to regular array
	path.invert()
	set_process(true)
	
func enter_password_zona(var shape):
	if shape.get_node("..").name == "Player":
		self.mode = PASSWORD_ZONA

func enter_password(viewport, event, shape_idx):
	if event is InputEventScreenTouch && event.pressed && self.mode == PASSWORD_ZONA:
		freeze()
		$Password/Terminal.show()
		
func freeze():
	set_process_input(false)
	for enemi in self.enemis:
		enemi.freeze()
	$Player.freeze()

func unfreeze():
	set_process_input(true)
	for enemi in self.enemis:
		enemi.unfreeze()
	$Player.unfreeze()

func _input(event):
	if (event is InputEventScreenTouch and event.pressed) || event is InputEventScreenDrag:
		begin = $Player.position
		# Mouse to local navigation coordinates
		end = $Camera2D + event.position - $Navigation2D.position
		$Player.destination = end
		$Player.set_move((end - begin).normalized())
#		update_path()

func shoot_bullet_from(var bullet):
	add_child(bullet)
	bullet.set_process(true)
	
func delete_object(var object):
	call_deferred("remove_child", object)
	if object.is_in_group("Enemis"):
		self.enemis.remove(self.enemis.find(object))
	object.call_deferred("queue_free")

func _on_Player_player_change_life(value):
	$HUD/LifeBar.value = value

func on_touched_enemi(var shape):
	path.clear()

func _on_Player_enter_in_another_area(var shape):
	var selectable = shape.get_node("..")
	if selectable.is_in_group("Movables"):
		path.clear()

func _on_Control_close_terminal():
	$Password/Terminal.hide()
	unfreeze()
	
func clear_enemis():
	var nb_enemis = self.enemis.size()
	for i in range(nb_enemis):
		delete_object(self.enemis[nb_enemis - i - 1])
	for node in get_children():
		if node.is_in_group("Bullets"):
			call_deferred("remove_child", node)
			node.call_deferred("queue_free")
			
func unlock_door():
	$Navigation2D/TileMap.set_cellv(self.door_tile, -1)
	$Navigation2D/TileMap.set_cellv(self.door_tile, 4)


func _on_Control_valid_password():
	print("valid password")
	$Password/Terminal.hide()
	clear_enemis()
	unfreeze()
	unlock_door()
