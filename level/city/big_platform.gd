extends Node2D

func get_size():
	return $StaticBody2D/CollisionShape2D.get_shape().get_extents() * 2
	
export var frequency = .4