extends Node

var paused : bool = false
var current_scene : Dictionary
var next_scene : Dictionary
var current_state : game_states = game_states.LOADING
var current_locale_id : int
var game_scene_flow := {
	#"Debug":
		#{
			#"res": "res://Scenes/Prototype/Prototype04.tscn",
			#"status": false,
			#"loadDialogue": false,
			#"playable": true
			#"name": "TestScene"
		#},
	"Prologue":
		{
			"res": "res://Scenes/Prologue.tscn",
			"status": false,
			"loadDialogue": true,
			"playable": false,
			"name": "Prologo"
		},
	"Map01":
		{
			"res": "res://Scenes/Prototype/Prototype01.tscn",
			"status": false,
			"loadDialogue": false,
			"playable": true,
			"name": "Mapa01"
		},
	"Interlude01":
		{
			"res": "res://Scenes/Interludes/Interlude01.tscn",
			"status": false,
			"loadDialogue": true,
			"playable": false,
			"name": "Interludio01"
		},
	"Map02":
		{
			"res": "res://Scenes/Prototype/Prototype02.tscn",
			"status": false,
			"loadDialogue": false,
			"playable": true,
			"name": "Mapa02"
		},
	"Interlude02":
		{
			"res": "res://Scenes/Interludes/Interlude02.tscn",
			"status": false,
			"loadDialogue": true,
			"playable": false,
			"name": "Interludio02"
		},
	"Map03":
		{
			"res": "res://Scenes/Prototype/Prototype03.tscn",
			"status": false,
			"loadDialogue": false,
			"playable": true,
			"name": "Mapa03"
		},
	"Interlude03":
		{
			"res": "res://Scenes/Interludes/Interlude03.tscn",
			"status": false,
			"loadDialogue": true,
			"playable": false,
			"name": "Interludio03"
		},
	"Map04":
		{
			"res": "res://Scenes/Prototype/Prototype04.tscn",
			"status": false,
			"loadDialogue": false,
			"playable": true, # true
			"name": "Mapa04"
		}
}

const PLAYER_NAME := "Margarita"
# var load_scene_after_dialogue : bool = false # deprecado

enum game_states {START, LOADING, PLAYING, PAUSED}

signal toggle_pause
signal toggle_loading
signal toggle_journal
signal toggle_controls
signal restart_game
signal toggle_playing

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	next_scene = game_scene_flow.Prologue

func _toggle_pause(emit := true) -> void:
	paused = !paused
	if (paused):
		current_state = game_states.PAUSED
	else: 
		current_state = game_states.PLAYING
	if emit:
		toggle_pause.emit()

# Funciones deprecadas
#func _set_load_scene_after_dialogue(value : bool) -> void:
	#load_scene_after_dialogue = value
#
#func _get_load_scene_after_dialogue() -> bool:
	#return load_scene_after_dialogue

func load_new_map(_new_map_path : String) -> void:
	for scene in game_scene_flow.keys():
		if not game_scene_flow[scene].status:
			print("Start loading new map: ", game_scene_flow[scene].res)
			current_scene = game_scene_flow[scene]
			_set_new_scene_path(game_scene_flow[scene])
			_toggle_loading()
			#print("Before: ")
			#print(game_scene_flow)
			game_scene_flow[scene].status = true
			#print("After: ")
			#print(game_scene_flow)
			break

func _toggle_loading() -> void:
	current_state = game_states.LOADING
	toggle_loading.emit()
	print("Toggled loading ok!")
	
func _toggle_playing() -> void:
	current_state = game_states.PLAYING
	toggle_playing.emit()
	print("Toggled playing ok!")

func _is_game_paused() -> bool:
	# print("_is_game_paused: ", (paused and current_state == game_states.PAUSED))
	return (paused and current_state == game_states.PAUSED)

func _get_new_scene_path() -> String:
	# print(next_scene.res)
	return next_scene.res

func _get_current_state() -> game_states:
	return current_state

func _set_new_scene_path(new_scene_path : Dictionary) -> void:
	next_scene = new_scene_path
	current_state = game_states.LOADING

func _switch_scene_loaded() -> void:
	current_scene = next_scene
	next_scene = {}
	current_state = game_states.PLAYING

func should_load_dialogue_at_start() -> bool:
	return current_scene.loadDialogue

func _is_game_loading() -> bool:
	# print("_is_game_loading: ", (current_state == game_states.LOADING))
	return (current_state == game_states.LOADING)

func _map01_completed_tasks() -> bool:
	return SceneManagerMap01._interacted_with_all()

func _map02_completed_tasks() -> bool:
	return SceneManagerMap02._interacted_with_all()

func _map03_completed_tasks() -> bool:
	return SceneManagerMap03._interacted_with_all()

func _map04_completed_tasks() -> bool:
	return SceneManagerMap04._interacted_with_all()

func _restart_game() -> void:
	paused = false
	current_scene = {}
	next_scene = game_scene_flow.Prologue
	current_state = game_states.LOADING
	current_locale_id = 0
	for key_scene in game_scene_flow.keys():
		game_scene_flow[key_scene].status = false
	restart_game.emit()
	get_tree().change_scene_to_file("res://Scenes/UI/Menu.tscn")

func _switch_language(lang : String) -> void:
	TranslationServer.set_locale(lang)
	match lang:
		"es":
			current_locale_id = 0
		"en":
			current_locale_id = 1

func _get_current_locale_id() -> int:
	return current_locale_id

func has_journal() -> bool:
	return SceneManagerMap01.already_interacted_with_journal()

func _toggle_journal() -> void:
	if has_journal():
		toggle_journal.emit()
	else:
		print("No tiene cuaderno todavía.")

func get_player_name() -> String:
	return PLAYER_NAME

func get_game_flow_names() -> Array:
	return game_scene_flow.keys()

func get_scene_state(scene_name : String) -> bool:
	return game_scene_flow[scene_name].status

func get_current_scene_name() -> String:
	return current_scene.name

func _toggle_controls(emit := true) -> void:
	if emit:
		toggle_controls.emit()
