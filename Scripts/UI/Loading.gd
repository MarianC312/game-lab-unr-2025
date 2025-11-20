extends Control

@onready var textLoading : RichTextLabel = $TextLoading
@onready var progress_bar : ProgressBar = $MarginContainer/ProgressBar

var progress : Array
var scene_load_status : int = 0

signal scene_loaded

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if GameManager.current_state == GameManager.game_states.LOADING:
		scene_load_status = ResourceLoader.load_threaded_get_status(GameManager._get_new_scene_path(), progress)
		progress_bar.value = progress[0] * 100

func _load_new_scene() -> void:
	ResourceLoader.load_threaded_request(GameManager._get_new_scene_path())

func _on_progress_bar_value_changed(value: float) -> void:
	if value == 100.0 and scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		#var new_scene = get_tree().call_deferred("change_scene_to_packed", ResourceLoader.load_threaded_get(GameManager._get_new_scene_path()))
		var new_scene = ResourceLoader.load_threaded_get(GameManager._get_new_scene_path())
		await get_tree().create_timer(0.2).timeout
		print("scene loaded!!")
		print("Value: ", value)
		print("scene_load_status: ", scene_load_status)
		emit_signal("scene_loaded", new_scene)
	else:
		print("Value: ", value)
		print("scene_load_status: ", scene_load_status)
