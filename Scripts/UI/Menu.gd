extends Control

func _ready() -> void:
	SceneTransitions.fade_in()

func _on_jugar_pressed() -> void:
	SceneTransitions.fade_out()
	
	await SceneTransitions.fade_complete
	
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/Game/Game.tscn")


func _on_playground_pressed() -> void:
	pass


func _on_opciones_pressed() -> void:
	pass # Replace with function body.


func _on_salir_pressed() -> void:
	SceneTransitions.fade_out()
	
	await SceneTransitions.fade_complete
	
	get_tree().quit()
