extends Control

export (DynamicFontData) var USED_FONT

signal valid_password
signal close_terminal

var SIZE_FONT = 90

var word

func set_password(var word):
	self.word = word
	$Name.set_text(word.name)
	var k = 0
	for i in word.translation:
		var line_edit = LineEdit.new()
		var font = DynamicFont.new()
		font.font_data = USED_FONT
		if word.translation.length() > 6 && word.translation.length() <= 8:
			font.size = SIZE_FONT - 10
		elif word.translation.length() > 8 && word.translation.length() <= 10:
			font.size = SIZE_FONT - 20
		elif word.translation.length() > 10:
			font.size = SIZE_FONT - 40
		else:
			font.size = SIZE_FONT
		font.use_mipmaps = true
		font.use_filter = true
		line_edit.set_align(LineEdit.ALIGN_CENTER)
		line_edit.add_font_override("font", font)
		line_edit.add_color_override("font_color", Color(1,1,1))
		line_edit.max_length = 1
		line_edit.add_constant_override("minimum_spaces", 0)
		line_edit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		line_edit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line_edit.rect_min_size = Vector2(SIZE_FONT,20)
		line_edit.connect("text_changed", self, "on_text_changed")
		var stylebox = StyleBoxFlat.new()
		stylebox.set_bg_color(Color(0,0,0,0))
		stylebox.set_border_color(Color(1,1,1,0.5))
		stylebox.border_width_bottom = 1
		line_edit.set('custom_styles/normal', stylebox)
		$Letters.add_child(line_edit)
		k+=1

func _on_AcceptPassword_button_up():
	var children = $Letters.get_children()
	for i in children.size():
		var line_edit = children[i]
		if word.translation[i].capitalize() != line_edit.get_text().capitalize():
			wrong_password()
			return
	emit_signal("valid_password")
	
func active_letter(var clue):
	var line_edit = $Letters.get_children()[clue.position]
	line_edit.set_text(clue.letter)
	line_edit.add_color_override("font_color", Color(1, 1, 0))
	line_edit.editable = false

func wrong_password():
	$AcceptPassword.add_color_override("font_color", Color(1,0,0))
	$AcceptPassword.add_color_override("font_color_pressed", Color(1,0,0))
	$AcceptPassword.add_color_override("font_color_hover", Color(1,0,0))

func _on_ExitButton_pressed():
	$AcceptPassword.add_color_override("font_color", Color(0,0,0))
	$AcceptPassword.add_color_override("font_color_pressed", Color(0,0,0))
	$AcceptPassword.add_color_override("font_color_hover", Color(0,0,0))
	emit_signal("close_terminal")

func on_text_changed(var s):
	if s.length():
		var index = -1
		var children = $Letters.get_children()
		for i in children.size():
			if $Letters.get_focus_owner() == children[i]:
				index = i + 1
		if index > -1:
			while index < children.size() && !children[index].editable:
				index+=1
			if index < children.size():
				children[index].grab_focus()
				
func clear():
	word = null
	$Name.set_text("")
	while $Letters.get_child_count() > 0:
		var child = $Letters.get_child(0)
		$Letters.remove_child(child)
		child.queue_free()