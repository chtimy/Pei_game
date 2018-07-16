extends Node2D

var begin = Vector2()
var end = Vector2()
var path = []

var enemis = []
var terminal_tile
var door_tile

enum {NORMAL_MODE = 0, PASSWORD_ZONA = 1}
var mode = NORMAL_MODE

func _ready():
	pass
	
func init_word():
	var word = {"name": "house", "translation" : "maison"}
	$Password/Terminal.set_password(word)
	return word.translation

#func update_path():
#	var p = $Navigation2D.get_simple_path(begin, end, true)
#	path = Array(p) # PoolVector2Array too complex to use, convert to regular array
#	path.invert()
#	set_process(true)
	
func on_enter_zone_terminal(var shape):
	if shape.get_node("..").name == "Player":
		print("change")
		self.mode = PASSWORD_ZONA
		
func on_exit_zone_terminal(var shape):
	if shape.get_node("..").name == "Player":
		self.mode = NORMAL_MODE

func on_click_on_terminal():
	if self.mode == PASSWORD_ZONA:
		freeze()
		$Password/Terminal.show()
		
func freeze():
	set_process_input(false)
	for enemi in self.enemis:
		enemi.freeze()
	$Player.freeze()

func unfreeze():
	set_process_input(true)
	for enemi in self.enemis:
		enemi.unfreeze()
	$Player.unfreeze()

func _input(event):
	if (event is InputEventScreenTouch and event.pressed) || event is InputEventScreenDrag:
		begin = $Player.position
		# Mouse to local navigation coordinates
		end = $Navigation2D.position + ($Player.position - get_viewport().get_size() * Vector2(0.5, 0.5)) + event.position
		$Player.destination = end
		$Player.set_move((end - begin).normalized())
		
#		update_path()

func shoot_bullet_from(var bullet):
	add_child(bullet)
	bullet.set_process(true)
	
func delete_object(var object):
	call_deferred("remove_child", object)
	if object.is_in_group("Enemis"):
		self.enemis.remove(self.enemis.find(object))
	object.call_deferred("queue_free")

func _on_Player_player_change_life(value):
	$HUD/Control/LifeBar.value = value

func on_touched_enemi(var shape):
	path.clear()

func _on_Player_enter_in_another_area(var shape):
	var selectable = shape.get_node("..")
	if selectable.is_in_group("Movables"):
		path.clear()

func _on_Control_close_terminal():
	$Password/Terminal.hide()
	unfreeze()
			
func unlock_door():
	$Navigation2D.get_children()[0].unlock_door()

func _on_Control_valid_password():
	$Password/Terminal.hide()
	clear_enemis()
	unfreeze()
	unlock_door()
	
func start_game():
	var word = init_word()
	$Navigation2D.generate(word.length()/2, word.length()/2 + 1, word)
#	$Navigation2D.init_enemis(word.length(), word)
	$HUD.init(self.enemis)
	$HUD/Control.show()
	
func stop_game():
#	$Player.call_deferred("queue_free")
	$HUD/Control.hide()

func _on_Player_player_died():
	$Menu/Control.show()
	stop_game()

func _on_Navigation2D_change_player_position(var position):
	$Player.position = position;
	$Player.stop()
