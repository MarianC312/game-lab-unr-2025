extends Control
const HOVER = preload("res://Sounds/SFX/UI/Seleccionar y hover/Hover.ogg")
const CONTINUAR_HACHAZO_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo 2.ogg")

@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_volver_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	GameManager._toggle_controls()

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()

func _on_hover() -> void:
	sfx_stream_player.stream = HOVER
	sfx_stream_player.play()
