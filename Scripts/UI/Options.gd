extends Control

@onready var lenguaje_option_button: OptionButton = $HBoxContainer3/LenguajeOptionButton
@onready var musica_slider: HSlider = $HBoxContainer/MusicaSlider
@onready var sonido_slider: HSlider = $HBoxContainer2/SonidoSlider
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	hide()
	lenguaje_option_button.selected = GameManager._get_current_locale_id()
	process_mode = Node.PROCESS_MODE_ALWAYS
	SceneTransitions.fade_complete.connect(_on_fade_complete)

func _on_volver_pressed() -> void:
	animation_player.play_backwards("slide_in_out")
	await animation_player.animation_finished
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	hide()

func _on_fade_complete() -> void:
	animation_player.play("slide_in_out")

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			GameManager._switch_language("es")
		1:
			GameManager._switch_language("en")
