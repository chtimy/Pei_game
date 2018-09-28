extends Control

signal next_level

func _on_ContinueButton_pressed():
	get_node("..").hide()
	emit_signal("next_level")