extends Node2D

# every module has to implement these methods
	
func get_size():
	return $StaticBody2D/CollisionShape2D.get_shape().get_extents() * 2
	
export var frequency = 1

