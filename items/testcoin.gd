extends Area2D

class_name Testcoin

func _ready():
	pass
	

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		Global.add_score(20)
		#print(Global.get_current_config()["PLAYER_STATS"])
		queue_free()
