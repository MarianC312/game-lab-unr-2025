extends Control

@onready var lenguaje_option_button: OptionButton = $VBoxContainer2/HBoxContainer3/LenguajeOptionButton

func _ready() -> void:
	hide()
	lenguaje_option_button.selected = GameManager._get_current_locale_id()
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_volver_pressed() -> void:
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	hide()


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			GameManager._switch_language("es")
		1:
			GameManager._switch_language("en")
