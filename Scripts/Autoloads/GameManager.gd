extends Node

var paused : bool = false

func _pause() -> void:
	paused = !paused

func _get_pause() -> bool:
	return paused
