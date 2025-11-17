extends Node

var paused : bool = false

signal toggle_pause

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _toggle_pause() -> void:
	paused = !paused
	emit_signal("toggle_pause")

func _get_pause() -> bool:
	return paused
