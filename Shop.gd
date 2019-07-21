extends Control

var health_cost = 10
var dagger_cost = 30

func _on_buy_dagger_pressed():
	var config = Global.get_current_config()
	if int(config["PLAYER_STATS"]["MONEY"]) >= dagger_cost:
		if Global.add_item("dagger"):
			Global.add_money(-dagger_cost)
			print("Dagger added!")
		else:
			print("You already own this item...")
	else:
		print("OOOOOF, ya fuckin' broke, boi")


func _on_buy_health_pressed():
	var config = Global.get_current_config()
	if int(config["PLAYER_STATS"]["MONEY"]) >= health_cost:
		Global.add_money(-health_cost)
		Global.add_health(5)
		print("New health: " + Global.get_current_config()["PLAYER_STATS"]["LIFE"])
	else:
		print("OOOOOF, ya fuckin' broke, boi")


func _on_return_button_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")
