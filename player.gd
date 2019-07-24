extends KinematicBody2D

const SPEED = 300
const GRAVITY = 20
const JUMP = 500

var velocity = Vector2()
var jumpCounter = 1
var baseJumps = 1
var score = 0

func _physics_process(delta):
	#print($AnimatedSprite.is_playing())
	velocity.y += GRAVITY 
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	else:
		velocity.x /= 1.2
	$AnimatedSprite.play("idle")
	
	"""
	if Global.invincible() and $AnimatedSprite.animation != "damage":
		$AnimatedSprite.play("damage")
	"""
	
	if Input.is_action_just_pressed("ui_up") && jumpCounter > 0:
		velocity.y = -JUMP
		jumpCounter -= 1
	
	if Input.is_action_just_pressed("ui_changeItem"):
		Global.change_to_next_item()
		
	if is_on_floor():
		jumpCounter = baseJumps
	if self.position.y > Global.get_lower_death_boundary():
		Global.return_to_title_screen()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collider = collision.collider
		if collider.get_name() == "end":
			Global.next_level()
		if collider.is_in_group("enemies"):
			# damage player
			damage(collider.get_damage())
	
func damage(var damage:int):
	Global.damage_player(damage)