extends Control

func _ready() -> void:
	SceneTransitions.fade_in()
	await SceneTransitions.fade_complete
	var scenetree : SceneTree = get_tree()
	await scenetree.create_timer(4.0).timeout
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	scenetree.change_scene_to_file("res://Scenes/UI/Menu.tscn")
