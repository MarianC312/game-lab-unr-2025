extends Node

@onready var music: AudioStreamPlayer = $Music

signal audio_stream_ready

var last_position : float = 0.0

func _ready() -> void:
	#audio_stream_ready.emit()
	#_play_music()
	pass

func _play_music() -> void:
	print(music)
	# music.play()

func _stop_music() -> void:
	# last_position = music.get_playback_position()
	music.stop()
