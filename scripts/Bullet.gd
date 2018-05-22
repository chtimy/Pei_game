extends Node2D

signal delete_object_from_Blaster

var direction
var target
var hit
var SPEED = 100

func _ready():
	connect("delete_object_from_Blaster", get_node(".."), "delete_object")
	
func _process(delta):
	position += Vector2(direction) * SPEED * delta

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	emit_signal("delete_object_from_Blaster", self)
