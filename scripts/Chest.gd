extends AnimatedSprite

signal find_treasure_sig

var treasure

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process_input(false)
	
func init(var treasure):
	self.treasure = treasure
	
func show():
	.show()
	$StaticBody2D.set_collision_layer_bit(0, 1)
	$StaticBody2D.set_collision_mask_bit(0, 1)
	set_process_input(true)

func _on_Trigger_input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch:
		play("opening")
		emit_signal("find_treasure_sig", self.treasure)
		set_process_input(false)
		
