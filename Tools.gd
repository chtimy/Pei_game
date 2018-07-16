extends Node

func randomize_array(var array):
	var n = array.size()
	for i in range(n):
		var k = (randi()%(n-i-1))+i+1
		var tmp = array[k]
		array[k] = array[i]
		array[i] = tmp
	return array