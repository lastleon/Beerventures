extends KinematicBody2D

onready var Player = get_tree().get_root().get_node("World/Node2D/Player")

const GRAVITY = 20
const SPEED = 30
const UP = Vector2(0, -1)
const JUMP_HEIGHT = -500

var motion = Vector2()
var direction = 1

var react_time = 200
var next_dir = 0
var next_dir_time = 0

var next_jump_time = -1

var target_player_dist = 140

var eye_reach = 100
var vision = 600

var timer = null
var jump_delay = 3
var can_jump = true

###########

export var damage = 20
export var spawn_frequency = .04

##########

func get_damage():
	return damage

func _ready():
	
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(jump_delay)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	
	
func on_timeout_complete():
	can_jump = true
	
func jump():
	if is_on_floor() && can_jump:
		motion.y = -600
		motion.x = SPEED * direction
		
		can_jump = false
		
		$AnimatedSprite.play("idle")
		
		timer.start()
	else:
		if position.y > Global.get_lower_death_boundary():
			queue_free()
		if motion.y < 0:
			$AnimatedSprite.play("jump_up")
		else:
			$AnimatedSprite.play("jump_down")

func set_dir(target_dir):
	if direction != target_dir:
		direction = target_dir
		next_dir_time = OS.get_ticks_msec() + react_time

func sees_player():
	var eye_center = get_global_position()
	var eye_top = eye_center + Vector2(0, -eye_reach)
	var eye_left = eye_center + Vector2(-eye_reach, 0)
	var eye_right = eye_center + Vector2(eye_reach, 0)

	var player_pos = Player.get_global_position()
	var player_extents = Player.get_node("CollisionShape2D").shape.extents - Vector2(1, 1)
	var top_left = player_pos + Vector2(-player_extents.x, -player_extents.y)
	var top_right = player_pos + Vector2(player_extents.x, -player_extents.y)
	var bottom_left = player_pos + Vector2(-player_extents.x, player_extents.y)
	var bottom_right = player_pos + Vector2(player_extents.x, player_extents.y)

	var space_state = get_world_2d().direct_space_state

	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for corner in [top_left, top_right, bottom_left, bottom_right]:
			if (corner - eye).length() > vision:
				continue
			var collision = space_state.intersect_ray(eye, corner, [], 1) # collision mask = sum of 2^(collision layers) - e.g 2^0 + 2^3 = 9
			if collision and collision.collider.name == "Player":
				return true
	return false

func _physics_process(delta):
	
	motion.y += GRAVITY
	
	
	jump()
	
	if Player.position.x < position.x - target_player_dist and sees_player():
		set_dir(-1)
	elif Player.position.x > position.x + target_player_dist and sees_player():
		set_dir(1)
	
	
	motion = move_and_slide(motion, UP)
	
	
	if is_on_wall():
		direction = direction * -1
		$RayCast2D.position.x *= -1
		
	if $RayCast2D.is_colliding() == false:
		direction = direction * -1
		$RayCast2D.position.x *= -1
