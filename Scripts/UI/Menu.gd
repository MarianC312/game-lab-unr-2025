extends Control

@onready var principal: Control = $CanvasLayer2/Principal
@onready var options_menu: Control = $CanvasLayer2/OptionsMenu

func _ready() -> void:
	SceneTransitions.fade_in()

func _on_jugar_pressed() -> void:
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/Game/Game.tscn")


func _on_playground_pressed() -> void:
	pass


func _on_opciones_pressed() -> void:
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	if options_menu.visible:
		options_menu.hide()
		# principal.move_to_front()
	else:
		options_menu.show()
		# options_menu.move_to_front()
	SceneTransitions.fade_in()
	await SceneTransitions.fade_complete
	# get_tree().call_deferred("change_scene_to_file", "res://Scenes/UI/Options.tscn")


func _on_salir_pressed() -> void:
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	get_tree().quit()
