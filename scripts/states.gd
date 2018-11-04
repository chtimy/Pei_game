extends Node

var level = 1
var stage = 1

var words = []
			
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
	while !file.eof_reached():
		var line = file.get_line().split(" ")
		var stage_cur = int(line[0])
		var nb_levels = int(line[1])
		words.append([])
		print(words)
		for l in range(nb_levels):
			line = file.get_line().split(" ")
			var level_cur = int(line[0])
			words[stage_cur-1].append([])
			var nb_words = int(line[1])
			for i in range(nb_words):
				line = file.get_line().split(":")
				words[stage_cur-1][level_cur-1].append({"name" : line[0], "translation" : line[1]})
	file.close()