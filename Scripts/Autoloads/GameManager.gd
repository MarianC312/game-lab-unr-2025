extends Node

var paused : bool = false
var current_scene : String
var next_scene : String
var current_state : game_states = game_states.LOADING

enum game_states {START, LOADING, PLAYING, PAUSED}

signal toggle_pause

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _toggle_pause() -> void:
	paused = !paused
	if (paused):
		current_state = game_states.PAUSED
	else: 
		current_state = game_states.PLAYING
	emit_signal("toggle_pause")

func _get_pause() -> bool:
	return paused

func _get_new_scene_path() -> String:
	return next_scene

func _set_new_scene_path(new_scene_path : String) -> void:
	next_scene = new_scene_path
	current_state = game_states.LOADING

func _switch_scene_loaded() -> void:
	current_scene = next_scene
	next_scene = ""
	current_state = game_states.PLAYING
