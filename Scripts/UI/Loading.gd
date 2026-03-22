extends Control

@onready var textLoading : Label = $TextLoading
@onready var progress_bar : ProgressBar = $MarginContainer/ProgressBar

var progress : Array
var scene_load_status : int = 0
var new_scene_path : String = ""
signal scene_loaded

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(_delta: float) -> void:
	if GameManager._is_game_loading() and progress_bar.value < 100.0:
		scene_load_status = ResourceLoader.load_threaded_get_status(new_scene_path, progress)
		progress_bar.value = progress[0] * 100
	else:
		on_full_progress()

func _load_new_scene() -> void:
	print("Called!")
	new_scene_path = GameManager._get_new_scene_path()
	ResourceLoader.load_threaded_request(new_scene_path)

func _on_progress_bar_value_changed(value: float) -> void:
	if value == 100.0 and scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		#var new_scene = get_tree().call_deferred("change_scene_to_packed", ResourceLoader.load_threaded_get(GameManager._get_new_scene_path()))
		on_full_progress()
	else:
		print("Value: ", value)
		print("scene_load_status: ", scene_load_status)
		print("ResourceLoader.THREAD_LOAD_LOADED: ", ResourceLoader.THREAD_LOAD_LOADED)
		await get_tree().create_timer(0.2).timeout

func _reset_progress_bar_value() -> void:
		progress_bar.value = 0
		scene_load_status = 1
		new_scene_path = ""
		

func on_full_progress() -> void:
	var new_scene = ResourceLoader.load_threaded_get(new_scene_path)
	await get_tree().create_timer(0.2).timeout
	print("scene loaded!!")
	print("Value: ", progress_bar.value)
	print("scene_load_status: ", scene_load_status)
	scene_loaded.emit(new_scene)
	
