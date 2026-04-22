extends Control
@onready var sfx_stream_player: AudioStreamPlayer = $SFXStreamPlayer
const CONTINUAR_HACHAZO_2 = preload("res://Sounds/SFX/UI/Seleccionar menu/Continuar hachazo 2.ogg")
const HOVER = preload("res://Sounds/SFX/UI/Seleccionar y hover/Hover.ogg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _play_sfx(sfx : Resource) -> void:
	sfx_stream_player.stream = sfx
	sfx_stream_player.play()

func _on_hover() -> void:
	sfx_stream_player.stream = HOVER
	sfx_stream_player.play()

func _on_volver_pressed() -> void:
	_play_sfx(CONTINUAR_HACHAZO_2)
	SceneTransitions.fade_out()
	await SceneTransitions.fade_complete
	hide()
