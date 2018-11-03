extends Control

signal next_level

func _on_ContinueButton_pressed():
	self.hide()
	emit_signal("next_level")

func win(var word):
	$State.set_text("Level complete")
	var s = word.name + "\n" +word.translation
	$Word.set_text(s)
	s = "Stage " + String(States.stage) + "\nLevel" + String(States.level)
	$Level.set_text(s)
	$Animation/AnimationPlayer.play("cat_animation")

func loose():
	$State.set_text("Game over")