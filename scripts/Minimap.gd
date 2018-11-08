extends Control

export (StreamTexture) var room
export (Vector2) var scale
export (StreamTexture) var open_chest_texture

var size_mat
var size_texture_room

var current_id

func _input(event):
	if event is InputEventScreenDrag:
		move_minimap(event.relative)

func init(var matrix, var id):
	self.size_mat = Vector2(matrix.size(), matrix[0].size())
	self.size_texture_room = room.get_size() * self.scale
	for i in range(size_mat.x):
		for j in range(size_mat.y):
			var sprite = Sprite.new()
			sprite.set_texture(room)
			sprite.set_scale(self.scale)
			sprite.set_position(Vector2(i * size_texture_room.x * 2, j * size_texture_room.y * 2))
			add_child(sprite)
	self.current_id = id
	change_room(id)

func change_room(var id):
	unfocus_on_room(self.current_id)
	self.current_id = id
	var offset = self.rect_size/2
	self.set_position(offset - id * self.size_texture_room * 2)
	get_node("../Player").set_position(get_room_global_position(id))
	focus_on_room(id)
	
func recenter():
	change_room(self.current_id)
	
func move_minimap(var translation):
	var new_position = get_position() + translation
	set_position(get_position() + translation)
	get_node("../Player").set_position(get_node("../Player").get_position() + translation)
	
func get_room_global_position(var id):
	var room = get_children()[id.x * self.size_mat.y + id.y]
	return room.get_global_position()
	
func focus_on_room(var id):
	change_room_color(id, Color(1,1,0,1))

func unfocus_on_room(var id):
	change_room_color(id, Color(1,1,1,1))

func change_room_color(var id, var color):
	var room = get_children()[id.x * self.size_mat.y + id.y]
	room.set_modulate(color) 
	
func finish_room(var id):
	var room = get_children()[id.x * self.size_mat.y + id.y]
	var sprite = Sprite.new()
	sprite.set_scale(Vector2(0.5, 0.5))
	sprite.set_texture(self.open_chest_texture)
	room.add_child(sprite)
