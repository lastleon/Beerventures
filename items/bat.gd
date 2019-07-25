extends Area2D

onready var Player = get_tree().get_root().get_node("World/Node2D/Player")

export var damage = 2

var collision_shape = CapsuleShape2D.new()

var time_since_last_use = 11
var max_time_since_last_use = 10

func _ready():
	collision_shape.set_radius(10)
	collision_shape.set_height(43)
	set_position(Vector2(30,30))
	reset_bat()

func flip_to_left():
	$CollisionShape2D.position = Vector2(-abs($CollisionShape2D.position.x), $CollisionShape2D.position.y)
	$AnimatedSprite.position = Vector2(-abs($AnimatedSprite.position.x), $AnimatedSprite.position.y)
	$AnimatedSprite.set_flip_h(true)

func flip_to_right():
	$CollisionShape2D.set_posi
	$CollisionShape2D.position = Vector2(abs($CollisionShape2D.position.x), $CollisionShape2D.position.y)
	$AnimatedSprite.position = Vector2(abs($AnimatedSprite.position.x), $AnimatedSprite.position.y)
	$AnimatedSprite.set_flip_h(false)

func reset_bat():
	$CollisionShape2D.shape = null
	$AnimatedSprite.play("idle")

func use_item():
	$CollisionShape2D.shape = collision_shape
	$AnimatedSprite.play("attack")
	time_since_last_use = 0


	
func _process(delta):
	
	if time_since_last_use > max_time_since_last_use:
		reset_bat()
	else:
		time_since_last_use += 1

func _on_bat_body_entered(body):
	if body.is_in_group("enemies"):
		body.damage(damage)
	reset_bat()


"""extends Area2D

var use_Frames = 0
const animation_Frames = 50
var damage = 1

onready var Player = get_tree().get_root().get_node("World/Node2D/Player")

func use_item():
	use_Frames = animation_Frames
	
func _physics_process(delta):
	if use_Frames > 0:
		get_node("CollisionShape2D").set_disabled(false)
		get_node("AnimatedSprite").play("attack")
		use_Frames -= 1
	else:
		get_node("CollisionShape2D").set_disabled(true)
		get_node("AnimatedSprite").play("idle")
	
	var player_pos = Player.get_global_position()
	var item_pos = get_global_position()
	
	var velocity = player_pos-item_pos
	move_and_slide(velocity,Vector2.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collider = collision.collider
		if collider.is_in_group("enemies"):
			collider.damage(damage)
			
		"""

