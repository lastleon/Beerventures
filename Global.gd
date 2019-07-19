extends Node

const LEVEL_LENGTH = 30
const LEVELS = ["city", "testworld"]

# this should be recognized automatically
var ALL_LEVEL_MODULES = parse_modules() # level : [modules]
var ALL_LEVEL_ENEMIES = parse_level_enemy_data() # level : {enemy : spawn_frequency(normalized to level)}
var level_index = 0

var frames_since_last_hit = 0
var invincibility_frames = 15
# this is always the starter-config
# more values will come soon
var config = {
	"LEVEL" : LEVELS[0],
	"LEVEL_COUNTER" : "1",
	"LEVEL_MODULES" : [],
	"ENEMIES" : [],
	"ENEMY_COUNT" : "10",
	"PLAYER_STATS": {
		"LIFE" : "10",
		"SCORE" : "0",
		"ITEMS" : [],
	}
}

func add_score(var points):
	config["PLAYER_STATS"]["SCORE"] = str(points + int(config["PLAYER_STATS"]["SCORE"]))

func damage_player(var damage):
	if invincible():
		frames_since_last_hit = 0
		config["PLAYER_STATS"]["LIFE"] = str(int(config["PLAYER_STATS"]["LIFE"]) - damage)
		
		if int(config["PLAYER_STATS"]["LIFE"]) <= 0:
			return_to_title_screen()

func return_to_title_screen():
	level_index = 0
	config["LEVEL"] = LEVELS[level_index]
	config["LEVEL_COUNTER"] = "1"
	config["LEVEL_MODULES"] = make_level()
	config["ENEMIES"] = make_enemy_array()
	config["ENEMY_COUNT"] = "10"
	
	config["PLAYER_STATS"]["LIFE"] = "10"
	config["PLAYER_STATS"]["SCORE"] = "0"
	# items stay the same
	
	get_tree().change_scene("res://TitleScreen.tscn")

func invincible() -> bool:
	return frames_since_last_hit >= invincibility_frames

func increment_frames_since_last_hit():
	if frames_since_last_hit < invincibility_frames:
		frames_since_last_hit += 1

func _ready():
	OS.set_window_resizable(false)
	config["LEVEL_MODULES"] = make_level()
	config["ENEMIES"] = make_enemy_array()

func get_current_config() -> Dictionary:
	return deep_copy(config)

func get_lower_death_boundary() -> float:
	return OS.get_window_size().y + 100

# builds a level
func make_level() -> Array:
	var path_to_modules = "res://level/" + config["LEVEL"] + "/"
	var modules = []
	
	# parse spawnfrequencies
	var module_frequency_pairs = []
	var summed_frequencies = 0
	for module in ALL_LEVEL_MODULES[config["LEVEL"]]:
		var frequency = load(path_to_modules + module + ".tscn").instance().frequency
		if frequency > 1:
			frequency = 1
		elif frequency < 0:
			frequency = 0
		
		module_frequency_pairs.append([module, frequency])
		summed_frequencies += frequency
	
	if summed_frequencies == 0:
		for i in range(LEVEL_LENGTH-1):
			var random_num = randint(0, len(config["LEVEL"]))
			modules.append(ALL_LEVEL_MODULES[config["LEVEL"]][random_num])
		
	else:
		var scale = 1/float(summed_frequencies)
	
		for i in range(LEVEL_LENGTH-1):
			var random_f = randfloat()
			var sum_of_frequencies = 0
			for pair in module_frequency_pairs:
	
				if sum_of_frequencies + (pair[1] * scale) >= random_f:
					modules.append(pair[0])
					break
				else:
					sum_of_frequencies += pair[1] * scale
	
	modules.append("end_platform")

	return modules

func make_enemy_array() -> Array:
	var enemies = []
	
	for i in range(config["ENEMY_COUNT"]):
		var random_f = randfloat()
		var sum_of_frequencies = 0
		
		for enemy in ALL_LEVEL_ENEMIES[config["LEVEL"]]:
			if sum_of_frequencies + ALL_LEVEL_ENEMIES[config["LEVEL"]][enemy] >= random_f:
				enemies.append(enemy)
				break
			else:
				sum_of_frequencies += ALL_LEVEL_ENEMIES[config["LEVEL"]][enemy]
	
	return enemies

func next_level() -> void:
	# here should come some code to save
	# the playerstats
	
	# if the current level is not the last level in the array "LEVELS"
	# then the next level is selected
	# otherwise it will stay the same 
	if not level_index == len(LEVELS)-1:
		level_index += 1
		config["LEVEL"] = LEVELS[level_index]
	config["LEVEL_MODULES"] = make_level()
	
	config["LEVEL_COUNTER"] = str(int(config["LEVEL_COUNTER"]) + 1)
	config["ENEMY_COUNT"] = str(floor(sqrt(int(config["LEVEL_COUNTER"])*5))+10)
	config["ENEMIES"] = make_enemy_array()
	
	
	get_tree().change_scene("res://world.tscn")

func get_start_position() -> Vector2:
	return Vector2(20,40)

func parse_modules() -> Dictionary:
	var path = "res://level/"
	var module_dict = {}
	# parsing the level directory
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var dirname = dir.get_next()
		while dirname != "":
			if dir.current_is_dir() and dirname != "." and dirname != "..":
				
				# parsing the levels
				var modulenames = []
				var dir2 = Directory.new()
				if dir2.open(path + dirname) == OK:
					dir2.list_dir_begin()
					var filename = dir2.get_next()
					while filename != "":
						if not dir2.current_is_dir() and filename.ends_with(".tscn") and dirname != "." and dirname != "..":
							modulenames.append(filename.replace(".tscn", ""))
						filename = dir2.get_next()
					module_dict[dirname] = modulenames
				else:
					print("There was a problem when trying to open the path: " + path + dirname + filename)
			
			dirname = dir.get_next()
	else:
		print("There was a problem when trying to open the path: " + path)
	
	return module_dict

func parse_level_enemy_data() -> Dictionary:
	# find all enemies
	var path = "res://enemies/"
	var all_enemies = {}
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if not dir.current_is_dir() and filename != "." and filename != ".." and filename.ends_with(".tscn"):
				var freq = load(path + filename).instance().get_node("KinematicBody2D").spawn_frequency
				if freq > 1:
					freq = 1
				elif freq < 0:
					freq = 0
				all_enemies[filename.replace(".tscn", "")] = freq
			filename = dir.get_next()
	else:
		print("There was a problem when trying to open the path: " + path)
	
	# make dict with possible enemies for each level
	path = "res://level/"
	var level_enemy_dict = {}
	for levelname in LEVELS:
		var enemies = []
		var enemies_with_freq = {}
		
		var file = File.new()
		if not file.file_exists(path + levelname + "/enemy_config.txt"):
			print("There is no enemy configuration for the level: " + levelname)
		else:
			file.open(path + levelname + "/enemy_config.txt", File.READ)
			
			var summed_spawn_frequencies = 0
			
			while not file.eof_reached():
				var line = file.get_line().strip_edges()
				if line in all_enemies:
					enemies.append(line)
					summed_spawn_frequencies += all_enemies[line]
				else:
					print("No enemy with name '" + line + "' exists...")
			
			for enemy in enemies:
				enemies_with_freq[enemy] = all_enemies[enemy] / summed_spawn_frequencies
		
		level_enemy_dict[levelname] = enemies_with_freq
		
	return level_enemy_dict
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		quit_game()

func quit_game():
	get_tree().quit()

## helper functions

static func randint(var a:int, var b:int) -> int:
	randomize()
	return int(floor(rand_range(a,b)))

static func randfloat() -> float:
	randomize()
	return randf()

static func deep_copy(v):
	var t = typeof(v)

	if t == TYPE_DICTIONARY:
		var d = {}
		for k in v:
			d[k] = deep_copy(v[k])
		return d

	elif t == TYPE_ARRAY:
		var d = []
		d.resize(len(v))
		for i in range(len(v)):
			d[i] = deep_copy(v[i])
		return d

	elif t == TYPE_STRING:
		var d = ""
		for c in v:
			d += c
		return d
	
	elif t == TYPE_OBJECT:
		if v.has_method("duplicate"):
			return v.duplicate()
		else:
			print("Found an object, but I don't know how to copy it!")