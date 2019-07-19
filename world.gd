extends Node

var loaded_scenes = {}
var loaded_enemies = {}

func _ready():
	var WIDTH = OS.get_window_size().x
	var HEIGHT = OS.get_window_size().y
	var config = Global.get_current_config()
	
	# background settings
	var background = $ParallaxBackground/ParallaxLayer/Background
	background.texture = load("res://level/" + config["LEVEL"] + "/res/background.png")
	background.centered = false
	var scale = HEIGHT / background.texture.get_size().y
	background.set_scale(Vector2(scale, scale))
	
	# parallax_layer settings
	var parallax_layer = $ParallaxBackground/ParallaxLayer
	parallax_layer.motion_mirroring = background.texture.get_size() * scale
	parallax_layer.motion_scale = Vector2(0.1,1)
	
	# player settings
	var player = load("res://player.tscn").instance()
	player.set_position(Global.get_start_position())
	add_child(player)
	
	# useful for the loop beneath
	var summed_length_of_level = 0
	
	# initialisation of modules
	for scene_name in config["LEVEL_MODULES"]:
		if not (scene_name in loaded_scenes):
			loaded_scenes[scene_name] = load("res://level/" + config["LEVEL"] + "/" + scene_name + ".tscn")
		var scene = loaded_scenes[scene_name].instance()
		scene.set_position(Vector2(summed_length_of_level, HEIGHT - 64))
		summed_length_of_level += scene.get_size().x
		add_child(scene)
	
	# spawn enemies
	for enemy_name in config["ENEMIES"]:
		if not (enemy_name in loaded_enemies):
			loaded_enemies[enemy_name] = load("res://enemies/" + enemy_name + ".tscn")
		var enemy = loaded_enemies[enemy_name].instance()
		enemy.set_position(Vector2(Global.randint(0, summed_length_of_level), OS.get_window_size().y / 2))
		enemy.get_node("KinematicBody2D").add_to_group("enemies")
		add_child(enemy)
		
	
	# camera settings
	var camera = $Node2D/Player/Camera2D
	camera.make_current()
	camera.limit_top = 0
	camera.limit_bottom = HEIGHT
	camera.limit_right =  summed_length_of_level
	camera.limit_left = 0 # limit_left has to be after limit_right

func _process(var delta):
	Global.increment_frames_since_last_hit()

func _on_Button_pressed():
	Global.return_to_title_screen()
