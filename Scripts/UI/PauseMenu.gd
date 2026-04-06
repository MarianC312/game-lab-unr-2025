extends Control
@onready var options_menu: Control = $OptionsMenu
@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer
const HOVER = preload("res://Sounds/SFX/UI/Seleccionar y hover/Hover.ogg")
const CONTINUAR_HACHAZO_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo 2.ogg")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_volver_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	GameManager._toggle_pause()


func _on_salir_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	get_tree().quit()


func _on_opciones_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
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


func _on_restart_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	GameManager._restart_game()

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()

func _on_hover() -> void:
	sfx_stream_player.stream = HOVER
	sfx_stream_player.play()
