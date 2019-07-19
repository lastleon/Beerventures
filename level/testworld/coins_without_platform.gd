extends Node2D

func get_size() -> Vector2:
	var width = 0
	var height = 0
	var sprite = get_child(0).get_node("Area2D/Sprite")
	var spacing = sprite.texture.get_size().x * sprite.get_scale().x
	for node in get_children():
		if node.position.x > width:
			width = node.position.x
		if node.position.y < height:
			height = node.position.y
	return Vector2(width + spacing, height)
	
export var frequency = 0.025