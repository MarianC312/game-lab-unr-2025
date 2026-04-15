extends Control

@onready var lenguaje_option_button: OptionButton = $HBoxContainer3/LenguajeOptionButton
@onready var musica_slider: HSlider = $HBoxContainer/MusicaSlider
@onready var sonido_slider: HSlider = $HBoxContainer2/SonidoSlider
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer
const CONTINUAR_HACHAZO_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo 2.ogg")

const HOVER = preload("res://Sounds/SFX/UI/Seleccionar y hover/Hover.ogg")

var already_faded := false
signal update_quality

func _ready() -> void:
	hide()
	lenguaje_option_button.selected = GameManager._get_current_locale_id()
	process_mode = Node.PROCESS_MODE_ALWAYS
	SceneTransitions.fade_complete.connect(_on_fade_complete)
	musica_slider.value_changed.connect(_on_musica_slider_changed)
	sonido_slider.value_changed.connect(_on_sonido_slider_changed)

	musica_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sonido_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))


func _on_volver_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	animation_player.play_backwards("slide_in_out")
	await animation_player.animation_finished
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	already_faded = false
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

func _on_musica_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sonido_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Player"), linear_to_db(value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), linear_to_db(value))


func _on_quality_option_button_item_selected(index: OptimizationManager.GraphicsQuality) -> void:
	print(index)
	OptimizationManager.set_graphics_quality(index)
	update_quality.emit()
