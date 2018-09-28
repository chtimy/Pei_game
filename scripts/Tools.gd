extends Node

enum DIRECTION{ VEC_RIGHT, VEC_NORTH_RIGHT, VEC_NORTH, VEC_NORTH_LEFT, VEC_SOUTH_RIGHT, VEC_SOUTH, VEC_SOUTH_LEFT, VEC_LEFT}

func randomize_array(var array):
	var n = array.size()
	for i in range(n-1):
		var k = (randi()%(n-i))
		var tmp = array[k]
		array[k] = array[i]
		array[i] = tmp
	return array
	
func get_direction(var vector):
	var angle = Vector2(1,0).angle_to(vector)
	if (angle >= 0.0 && angle < PI/8.0) || (angle <= 0.0 && angle > -PI/8.0):
		return VEC_RIGHT
	elif angle >= PI/8.0 && angle < 3 * PI/8.0:
		return VEC_SOUTH_RIGHT
	elif angle >= 3 * PI/8.0 && angle < 5 * PI/8.0:
		return VEC_SOUTH
	elif angle >= 5 * PI/8.0 && angle < 7 * PI/8.0:
		return VEC_SOUTH_LEFT
	elif (angle >= 7 * PI/8.0 && angle <= PI) || (angle >= -PI && angle < -7 * PI/8.0):
		return VEC_LEFT
	elif angle >= -7 * PI/8.0 && angle < -5 * PI/8.0:
		return VEC_NORTH_LEFT
	elif angle >= -5 * PI/8.0 && angle < -3*PI/8.0:
		return VEC_NORTH
	elif angle >= -3 * PI/8.0 && angle <= -PI/8.0:
		return VEC_NORTH_RIGHT
	
func get_direction_value(var direction):
	if direction == VEC_RIGHT:
		return Vector2(1, 0)
	elif direction == VEC_LEFT:
		return Vector2(-1, 0)
	elif direction == VEC_NORTH:
		return Vector2(0,-1)
	elif direction == VEC_SOUTH:
		return Vector2(0,1)
	elif direction == VEC_NORTH_RIGHT:
		return Vector2(-0.5,0.5).normalized()
	elif direction == VEC_SOUTH_RIGHT:
		return Vector2(0.5,0.5).normalized()
	elif direction == VEC_SOUTH_LEFT:
		return Vector2(-0.5,0.5).normalized()
	elif direction == VEC_NORTH_LEFT:
		return Vector2(-0.5,-0.5).normalized()
	