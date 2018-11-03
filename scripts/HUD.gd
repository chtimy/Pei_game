extends CanvasLayer
signal moving_stick
signal stop_moving_stick

var touching_moving_stick = false

func _ready():
	$Joystick.position = $TouchScreenButton2.position
	connect("moving_stick", get_node("../image/Player"), "set_move")
	connect("stop_moving_stick", get_node("../image/Player"), "stop")

func _process(var delta):
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
