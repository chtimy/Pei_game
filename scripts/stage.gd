extends Control

signal enter_stage

func _on_TouchScreenButton2_pressed():
	for area in $image/Player/Trigger.get_overlapping_areas():
		print(area.get_name())
		if area.get_name() == "kitchen_trigger":
			emit_signal("enter_stage", 1, 1)