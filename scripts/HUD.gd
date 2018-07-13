extends CanvasLayer

export (StreamTexture) var ENEMI_TEXTURE
var size_radar
var ratio

func _ready():
	set_process(false)

func init(var enemis):
	self.size_radar = $Control/ViewportContainer.get_size()
	self.ratio = self.size_radar.length() / get_node("../Navigation2D").cell_size.length()
	var player_position = get_node("../Player").get_position()
	var central_position = self.size_radar / Vector2(2,2)
	for enemi in enemis:
		var sprite = Sprite.new()
		sprite.set_texture(ENEMI_TEXTURE)
		var vec = enemi.position - player_position
		sprite.set_position(central_position + vec * self.ratio)
		$Control/ViewportContainer/radar.add_child(sprite)
	set_process(true)

func _process(var delta):
	var enemis = get_node("..").enemis
	var player_position = get_node("../Player").get_position()
	var children = $Control/ViewportContainer/radar.get_children()
	var central_position = self.size_radar / Vector2(2,2)
	for i in range(enemis.size()):
		var sprite = children[i]
		sprite.set_position((enemis[i].position - player_position) * self.ratio)
		sprite.modulate.a = 1 - (sprite.position.length() / self.size_radar.length() * 2)