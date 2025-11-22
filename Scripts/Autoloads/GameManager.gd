extends Node

var paused : bool = false
var current_scene : String
var next_scene : String
var current_state : game_states = game_states.LOADING
var load_scene_after_dialogue : bool = false

enum game_states {START, LOADING, PLAYING, PAUSED}

signal toggle_pause
signal toggle_loading

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _toggle_pause() -> void:
	paused = !paused
	if (paused):
		current_state = game_states.PAUSED
	else: 
		current_state = game_states.PLAYING
	emit_signal("toggle_pause")

func _set_load_scene_after_dialogue(value : bool) -> void:
	load_scene_after_dialogue = value

func _get_load_scene_after_dialogue() -> bool:
	return load_scene_after_dialogue

func load_new_map(new_map_path : String) -> void:
	print("Start loading new map: ", new_map_path)
	_set_new_scene_path(new_map_path)
	await get_tree().create_timer(0.2).timeout
	_toggle_loading()

func _toggle_loading() -> void:
	current_state = game_states.LOADING
	emit_signal("toggle_loading")
	print("Toggled loading ok!")
	
func _toggle_playing() -> void:
	current_state = game_states.PLAYING
	print("Toggled playing ok!")

func _is_game_paused() -> bool:
	return (paused and current_state == game_states.PAUSED)

func _get_new_scene_path() -> String:
	return next_scene

func _get_current_state() -> game_states:
	return current_state

func _set_new_scene_path(new_scene_path : String) -> void:
	next_scene = new_scene_path
	current_state = game_states.LOADING

func _switch_scene_loaded() -> void:
	current_scene = next_scene
	next_scene = ""
	current_state = game_states.PLAYING

func _is_game_loading() -> bool:
	return current_state == game_states.LOADING
