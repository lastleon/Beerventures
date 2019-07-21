extends Area2D

class_name Testcoin

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		Global.add_money(20)
		queue_free()
