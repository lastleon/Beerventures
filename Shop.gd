extends Control


func _on_Button1_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")


func _on_Button2_pressed():
	Global.baseLife += 1