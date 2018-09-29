extends Control

signal next_level

func _on_ContinueButton_pressed():
	self.hide()
	emit_signal("next_level")

func init(var word):
	var s = word.name + "\n" +word.translation
	$Word.set_text(s)
	s = "Stage " + String(States.stage) + "\nLevel" + String(States.level)
	$Level.set_text(s)