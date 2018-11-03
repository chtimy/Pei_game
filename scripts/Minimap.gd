extends Control

export (StreamTexture) var room
var size_mat
var size_texture_room

func init(var matrix, var current_map_id):
	self.size_mat = Vector2(matrix.size(), matrix[0].size())
	self.size_texture_room = room.get_size()
	for i in range(size_mat.x):
		for j in range(size_mat.y):
			var sprite = Sprite.new()
			sprite.set_texture(room)
			sprite.set_position(Vector2(i * size_texture_room.x * 2, j * size_texture_room.y * 2))
			add_child(sprite)
	change_room(current_map_id)

func change_room(var current_map_id):
	self.set_position(self.rect_size/2 + self.size_texture_room * 2 * current_map_id)