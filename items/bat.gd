extends Area2D

onready var Player = get_tree().get_root().get_node("World/Node2D/Player")

export var damage = 2

var time_since_last_use = 11
var max_time_since_last_use = 10
###########################################              dis shit isn't working !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
func reset_bat():
	$CollisionShape2D.set_disabled(true)
	$Sprite.visible = true
	$AnimatedSprite.visible = false

func use_item():
	$Sprite.visible = false
	
	$CollisionShape2D.set_disabled(false)
	
	$AnimatedSprite.visible = true
	$AnimatedSprite.play("attack")
	

func _ready():
	set_position(Vector2(30,30))
	reset_bat()

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

