extends Control

@onready var lenguaje_option_button: OptionButton = $HBoxContainer3/LenguajeOptionButton
@onready var musica_slider: HSlider = $HBoxContainer/MusicaSlider
@onready var sonido_slider: HSlider = $HBoxContainer2/SonidoSlider
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer
const CONTINUAR_HACHAZO_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo 2.wav")

const HOVER = preload("res://Sounds/SFX/UI/Seleccionar y hover/Hover.wav")

var already_faded := false


func _ready() -> void:
	hide()
	lenguaje_option_button.selected = GameManager._get_current_locale_id()
	process_mode = Node.PROCESS_MODE_ALWAYS
	SceneTransitions.fade_complete.connect(_on_fade_complete)

func _on_volver_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	animation_player.play_backwards("slide_in_out")
	await animation_player.animation_finished
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	hide()

func _on_fade_complete() -> void:
	if not already_faded:
		animation_player.play("slide_in_out")
		already_faded = true

func _on_option_button_item_selected(index: int) -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	match index:
		0:
			GameManager._switch_language("es")
		1:
			GameManager._switch_language("en")

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()

func _on_hover() -> void:
	sfx_stream_player.stream = HOVER
	sfx_stream_player.play()
