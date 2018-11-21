extends Node

var level = 1
var stage = 1

var words = []
var used_words = []
var unlock_level = []

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
		used_words.append([])
		unlock_level.append([])
		for l in range(nb_levels):
			line = file.get_line().split(" ")
			var level_cur = int(line[0])
			words[stage_cur-1].append([])
			used_words[stage_cur-1].append([])
			unlock_level[stage_cur-1].append(int(line[2]))
			var nb_words = int(line[1])
			for i in range(nb_words):
				line = file.get_line().split(":")
				words[stage_cur-1][level_cur-1].append({"name" : line[0], "translation" : line[1]})
	file.close()
	
func finish_word(var found_word, var stage_id, var level_id):
	print("finish word : ",found_word)
	print(words[stage_id-1][level_id-1])
	var index = get_word_index_in_level(stage_id-1, level_id-1, States.words, found_word)
	if index != -1:
		words[stage_id-1][level_id-1].remove(index)
		used_words[stage_id-1][level_id-1].append(found_word)
	
func get_nb_used_words():
	var t = 0
	for i in range(self.used_words.size()):
		for j in range(self.used_words[i].size()):
			t += self.used_words[i][j].size()
	return t
					
func get_word_index_in_level(var stage_id, var level_id, var words, var searched_word):
	for k in range(words[stage_id][level_id].size()):
		if words[stage_id][level_id][k].name == searched_word.name && words[stage_id][level_id][k].translation == searched_word.translation:
			return k
	return -1
	
func print_size():
	print("words : size stages ", self.words.size())
	for i in range(self.words.size()):
		print("size levels ", words[i].size())
		for j in range(self.words[i].size()):
			print("size words ", words[i][j].size())
	print("used_words : size stages ", self.used_words.size())
	for i in range(self.used_words.size()):
		print("size levels ", used_words[i].size())
		for j in range(self.words[i].size()):
			print("size words ", used_words[i][j].size())
		