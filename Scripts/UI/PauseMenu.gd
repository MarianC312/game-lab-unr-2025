extends Control
@onready var options_menu: Control = $OptionsMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_volver_pressed() -> void:
	GameManager._toggle_pause()


func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_opciones_pressed() -> void:
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	if options_menu.visible:
		options_menu.hide()
		# principal.move_to_front()
	else:
		options_menu.show()
		# options.move_to_front()
	SceneTransitions.fade_in()
	await SceneTransitions.fade_complete
