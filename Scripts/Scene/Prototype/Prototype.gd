extends Node3D

signal map_ready

func _ready() -> void:
	emit_signal("map_ready")
	print("Mapa listo!")
