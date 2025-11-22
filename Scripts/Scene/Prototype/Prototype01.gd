extends Node3D

signal map_ready

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	emit_signal("map_ready")
	print("Mapa listo!")
