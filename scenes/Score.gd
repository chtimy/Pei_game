extends Control

signal next_level
	
func _on_Button_continue_game():
	emit_signal("next_level")