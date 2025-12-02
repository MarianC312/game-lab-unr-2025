@tool
extends Node

func _process(_delta: float) -> void:
	var vec1 = Vector3(1, 1, 3)
	var vec2 = Vector3(3, 1, 1)
	var direction = vec1 - vec2
	print(direction)
	print((vec1 - vec2).normalized())
	print()
	
	pass
