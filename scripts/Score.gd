extends Control

signal next_level

func _on_ContinueButton_pressed():
	self.hide()
	emit_signal("next_level")
