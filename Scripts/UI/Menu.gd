extends Control

@onready var panel: Panel = $CanvasLayer2/Principal/Panel
@onready var principal: Control = $CanvasLayer2/Principal
@onready var options_menu: Control = $CanvasLayer2/OptionsMenu
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer
const HOVER = preload("res://Sounds/SFX/UI/Seleccionar y hover/Hover.wav")
const SELECCIONAR_OPCIONES = preload("res://Sounds/SFX/UI/Seleccionar y hover/Seleccionar opciones.wav")
const CONTINUAR_HACHAZO_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo 2.wav")
const CONTINUAR_HACHAZO_MAS_CAIDA_ARBOL_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo mas caida arbol 2.wav")


func _ready() -> void:
	audio_stream_player.play()
	options_menu.hide()
	SceneTransitions.fade_in()

func _on_jugar_pressed() -> void:
	# pasar volume_db a -50 para mutear sonido luego pausar
	_play_sfx(CONTINUAR_HACHAZO_MAS_CAIDA_ARBOL_2)
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	panel.show()
	await sfx_stream_player.finished
	smooth_fade()
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/Game/Game.tscn")

func smooth_fade():
	for i in range(8): # paso
		audio_stream_player.volume_db = audio_stream_player.volume_db - 7.0 # cantidad volumen a bajar
		await get_tree().create_timer(0.1).timeout
	audio_stream_player.stop()

func _on_playground_pressed() -> void:
	pass

func _on_opciones_pressed() -> void:
	_play_sfx(SELECCIONAR_OPCIONES)
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
	_play_sfx(CONTINUAR_HACHAZO_2)
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	get_tree().quit()

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()

func _on_hover() -> void:
	sfx_stream_player.stream = HOVER
	sfx_stream_player.play()
