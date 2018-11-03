extends Node

enum DIRECTION{ VEC_RIGHT, VEC_NORTH_RIGHT, VEC_NORTH, VEC_NORTH_LEFT, VEC_SOUTH_RIGHT, VEC_SOUTH, VEC_SOUTH_LEFT, VEC_LEFT, VEC_NORTH_RIGHT, VEC_RIGHT_NORTH, VEC_SOUTH_RIGHT, VEC_RIGHT_SOUTH, VEC_NORTH_LEFT, VEC_LEFT_NORTH, VEC_SOUTH_LEFT, VEC_LEFT_SOUTH}

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
	elif angle >= PI/8.0 && angle < 2 * PI/8.0:
		return VEC_RIGHT_SOUTH
	elif angle >= 2 * PI/8.0 && angle < 3 * PI/8.0:
		return VEC_SOUTH_RIGHT
	elif angle >= 3 * PI/8.0 && angle < 5 * PI/8.0:
		return VEC_SOUTH
	elif angle >= 5 * PI/8.0 && angle < 6 * PI/8.0:
		return VEC_SOUTH_LEFT
	elif angle >= 6 * PI/8.0 && angle < 7 * PI/8.0:
		return VEC_LEFT_SOUTH
	elif (angle >= 7 * PI/8.0 && angle <= PI) || (angle >= -PI && angle < -7 * PI/8.0):
		return VEC_LEFT
	elif angle >= -7 * PI/8.0 && angle < -6 * PI/8.0:
		return VEC_LEFT_NORTH
	elif angle >= -6 * PI/8.0 && angle < -5 * PI/8.0:
		return VEC_NORTH_LEFT
	elif angle >= -5 * PI/8.0 && angle < -3 * PI/8.0:
		return VEC_NORTH
	elif angle >= -3 * PI/8.0 && angle <= -2 * PI/8.0:
		return VEC_NORTH_RIGHT
	elif angle >= -2 * PI/8.0 && angle <= -PI/8.0:
		return VEC_RIGHT_NORTH
		
func close_ref_vec(var direction, var div):
	var i = -PI
	while i <= PI:
		var ref_vec = Vector2(cos(i), sin(i))
		if ref_vec.angle_to(direction) <= 2 * PI / div:
			return ref_vec
		i += 2.0 *PI / div
	return null
	
func point_is_inside_triangle(var p, var a, var b, var c):
#	print("inside triangle : ", a, " ", b, " " , c, " point:", p)
	var v = (b-a).normalized()
	var v2 = (c-a).normalized()
	var v3 = (p-a).normalized()
#	print("angles : ", abs(v.angle_to(v3)), " ", abs(v.angle_to(v2)))
	if abs(v.angle_to(v3)) >= abs(v.angle_to(v2)):
		return false
	v = (a-b).normalized()
	v2 = (c-b).normalized()
	v3 = (p-b).normalized()
#	print("angles : ", abs(v.angle_to(v3)), " ", abs(v.angle_to(v2)))
	if abs(v.angle_to(v3)) >= abs(v.angle_to(v2)):
		return false
	return true
#func get_direction_value(var direction):
#	var PI16 = PI/16.0
#	if direction == VEC_RIGHT:
#		return Vector2(1, 0)
#	elif direction == VEC_RIGHT_NORTH:
#		return Vector2(cos(-3 * PI16), sin(-3 * PI16))
#	elif direction == VEC_RIGHT_SOUTH:
#		return Vector2(cos(3 * PI16), sin(3 * PI16))
#	elif direction == VEC_LEFT:
#		return Vector2(-1, 0)
#	elif direction == VEC_LEFT_SOUTH:
#		return Vector2(cos(13 * PI16), sin(13 * PI16))
#	elif direction == VEC_LEFT_NORTH:
#		return Vector2(cos(-13 * PI16), sin(-13 * PI16))
#	elif direction == VEC_NORTH:
#		return Vector2(0,-1)
#	elif direction == VEC_NORTH_RIGHT:
#		return Vector2(cos(-7 * PI16), sin(-7 * PI16))
#	elif direction == VEC_NORTH_LEFT:
#		return Vector2(cos(-9 * PI16), sin(-9 * PI16))
#	elif direction == VEC_SOUTH:
#		return Vector2(0,1)
#	elif direction == VEC_SOUTH_RIGHT:
#		return Vector2(cos(5 * PI16), sin(5 * PI16))
#	elif direction == VEC_SOUTH_LEFT:
#		return Vector2(cos(-5 * PI16), sin(-5 * PI16))
#	elif direction == VEC_NORTH_RIGHT:
#		return Vector2(-0.5,0.5).normalized()
#	elif direction == VEC_SOUTH_RIGHT:
#		return Vector2(0.5,0.5).normalized()
#	elif direction == VEC_SOUTH_LEFT:
#		return Vector2(-0.5,0.5).normalized()
#	elif direction == VEC_NORTH_LEFT:
#		return Vector2(-0.5,-0.5).normalized()
#