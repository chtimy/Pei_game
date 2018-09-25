extends CanvasLayer
signal moving_stick
signal stop_moving_stick
signal attack_button
export (StreamTexture) var ENEMI_TEXTURE
var size_radar
var ratio

var touching_moving_stick = false

func _ready():
	pass

func init():
#	self.size_radar = $Control/ViewportContainer.get_size()
#	self.ratio = self.size_radar.length() / get_node("../Game").cell_size.length()
#	var player_position = get_node("../Game/Player").get_position()
#	var central_position = self.size_radar / Vector2(2,2)
#	for enemi in enemis:
#		var sprite = Sprite.new()
#		sprite.set_texture(ENEMI_TEXTURE)
#		var vec = enemi.position - player_position
#		sprite.set_position(central_position + vec * self.ratio)
#		$Control/ViewportContainer/radar.add_child(sprite)
	set_process(true)

func _process(var delta):
#	var enemis = get_node("..").enemis
#	var player_position = get_node("../Game/Player").get_position()
#	var children = $Control/ViewportContainer/radar.get_children()
#	var central_position = self.size_radar / Vector2(2,2)
#	for i in range(enemis.size()):
#		var sprite = children[i]
#		sprite.set_position((enemis[i].position - player_position) * self.ratio)
#		sprite.modulate.a = 1 - (sprite.position.length() / self.size_radar.length() * 2)
	if touching_moving_stick:
		emit_signal("moving_stick", 
				(get_viewport().get_mouse_position() - $TouchScreenButton2.position).normalized(),
				get_viewport().get_mouse_position().distance_to($TouchScreenButton2.position) / float($TouchScreenButton2.get_shape().radius))

func _on_TouchScreenButtonMove_pressed():
	touching_moving_stick = true
	
func _on_TouchScreenButtonMove_released():
	touching_moving_stick = false
	call_deferred("emit_signal", "stop_moving_stick")


func _on_TouchScreenButton_pressed():
	call_deferred("emit_signal", "attack_button")
