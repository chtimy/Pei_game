extends CanvasLayer
signal moving_stick
signal stop_moving_stick
signal attack_button
signal show_minimap
export (StreamTexture) var ENEMI_TEXTURE
var size_radar
var ratio

var touching_moving_stick = false

func _ready():
	$Joystick.position = $TouchScreenButton2.position
	connect("show_minimap", get_node(".."), "show_minimap")

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
		var mouse_position = get_viewport().get_mouse_position()
		var center = $TouchScreenButton2.position
		var vec = mouse_position - center
		var radius = $TouchScreenButton2.get_shape().radius
		if vec.length() <= radius:
			$Joystick.position = mouse_position
		else:
			$Joystick.position = center + vec.clamped(radius)
		var factor = clamp(mouse_position.distance_to(center) / float(radius), 0.0, 1.0)
		emit_signal("moving_stick", 
				(get_viewport().get_mouse_position() - $TouchScreenButton2.position).normalized(), factor)
			
func _on_TouchScreenButtonMove_pressed():
	touching_moving_stick = true
	
func _on_TouchScreenButtonMove_released():
	touching_moving_stick = false
	$Joystick.position = $TouchScreenButton2.position
	call_deferred("emit_signal", "stop_moving_stick")

func _on_TouchScreenButton_pressed():
	call_deferred("emit_signal", "attack_button")
	
func hide():
	$Control.hide()
	$TouchScreenButton.hide()
	$TouchScreenButton2.hide()
	$border.hide()
	$Joystick.hide()
	
func show():
	$Control.show()
	$TouchScreenButton.show()
	$TouchScreenButton2.show()
	$border.show()
	$Joystick.show()

func _on_Menu_Acess_pressed():
	emit_signal("show_minimap")
