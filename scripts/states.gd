extends Node

var level = 1
var stage = 1

var words = [
			 [
			  {"name": "fork", "translation" : "fourchette"}, 
			  {"name": "knife", "translation" : "couteau"},
			  {"name": "plate", "translation" : "assiette"},
			  {"name": "glass", "translation" : "verre"},
			  {"name": "spoon", "translation" : "cuillère"},
			  {"name": "napkin", "translation" : "serviette"}
			 ]
			]
			
var used_words = [[]]

func read_dictionnary():
	var file = File.new()
	if !file.file_exists("dictionnary.txt"):
		print("Error, no dictionnary found")
		get_tree().quit()
	file.open("dictionnary.txt", File.READ)
	if !file.is_open():
		print("Error, dictionnary can't be opened")
		get_tree().quit()
	var line = file.get_line().split(" ")
	print(line)
	var stage = int(line[0])
	var level = int(line[1])
	var nb_words = int(line[2])
	print(stage, " ", level, " ", nb_words)
	file.close()