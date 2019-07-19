extends Control


func _on_Button_pressed():
	get_tree().change_scene("res://world.tscn")


func _on_Button3_pressed():
	Global.quit_game()


func _on_Button2_pressed():
	get_tree().change_scene("res://Shop.tscn")