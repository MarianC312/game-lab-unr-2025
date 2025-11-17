extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_volver_pressed() -> void:
	GameManager._toggle_pause()


func _on_salir_pressed() -> void:
	get_tree().quit()
